//VENUS MODULE - Copied from Splurt's thirst module, with modifications for thirst bar
/datum/hud
	var/atom/movable/screen/thirst

/datum/hud/Destroy()
	. = ..()
	thirst = null

/mob/living/proc/get_hydration()
	var/hydration_val = water_level
	if(!reagents)
		return hydration_val
	for(var/datum/reagent/bits in reagents.reagent_list)
		if(bits.hydration)
			// We use the same formula as hunger's get_fullness()
			hydration_val += bits.hydration * bits.volume / bits.metabolization_rate
	return hydration_val

/atom/movable/screen/thirst
	name = "thirst"
	icon_state = "hungerbar"
	screen_loc = ui_thirst
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// What state of thirst are we in?
	VAR_PRIVATE/state
	/// What hydration level (processed + pending) did we last record?
	VAR_PRIVATE/hydration
	/// What icon do we show by the bar
	var/food_icon = 'icons/obj/drinks/mixed_drinks.dmi'
	/// What icon state do we show by the bar
	var/food_icon_state = "four_bit"
	/// The image shown by the bar.
	VAR_PRIVATE/image/food_image
	/// The actual bar
	VAR_PRIVATE/atom/movable/screen/thirst_bar/thirst_bar

/atom/movable/screen/thirst/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/mob/living/thirsty = hud_owner?.mymob
	if(!istype(thirsty))
		return

	if(!ishuman(thirsty) || CONFIG_GET(flag/disable_human_mood))
		screen_loc = ui_mood

	food_image = image(icon = food_icon, icon_state = food_icon_state, pixel_x = -5)
	food_image.plane = plane
	food_image.appearance_flags |= KEEP_APART
	food_image.add_filter("simple_outline", 2, outline_filter(1, COLOR_BLACK, OUTLINE_SHARP))
	underlays += food_image

	// The actual bar
	thirst_bar = new(src, null)
	vis_contents += thirst_bar

	update_thirst_bar(instant = TRUE)

/atom/movable/screen/thirst/proc/update_thirst_state()
	var/mob/living/thirsty = hud?.mymob
	if(!istype(thirsty))
		return

	if(HAS_TRAIT(thirsty, TRAIT_NOTHIRST) || !thirsty.get_organ_slot(ORGAN_SLOT_STOMACH))
		hydration = THIRST_LEVEL_QUENCHED
		state = THIRST_STATE_FINE
		return

	hydration = round(clamp(thirsty.get_hydration(), 0, THIRST_LEVEL_THRESHOLD), 0.05)

	switch(hydration)
		if(1 + THIRST_LEVEL_THRESHOLD to INFINITY)
			state = THIRST_STATE_FAT
		if(1 + THIRST_LEVEL_FULL to THIRST_LEVEL_THRESHOLD)
			state = THIRST_STATE_FULL
		if(1 + THIRST_LEVEL_BIT_THIRSTY to THIRST_LEVEL_FULL)
			state = THIRST_STATE_FINE
		if(1 + THIRST_LEVEL_THIRSTY to THIRST_LEVEL_BIT_THIRSTY)
			state = THIRST_STATE_FINE
		if(1 + THIRST_LEVEL_PARCHED to THIRST_LEVEL_THIRSTY)
			state = THIRST_STATE_HUNGRY
		if(0 to THIRST_LEVEL_PARCHED)
			state = THIRST_STATE_STARVING

/atom/movable/screen/thirst/update_appearance(updates)
	update_thirst_bar()
	return ..()

/// Updates the thirst bar's appearance.
/// If `instant` is TRUE, the bar will update immediately rather than animating.
/atom/movable/screen/thirst/proc/update_thirst_bar(instant = FALSE)
	var/old_state = state
	var/old_hydration = hydration
	update_thirst_state()

	if(old_state != state || old_hydration != hydration)
		// Fades out if we ARE "fine" AND if our hydration isn't changing (processed == total)
		var/mob/living/thirsty = hud?.mymob
		if(alpha == 255 && (state == THIRST_STATE_FINE && abs(hydration - thirsty?.water_level) < 1))
			if(instant)
				alpha = 0
			else
				animate(src, alpha = 0, time = 1 SECONDS)
		// Fades in if we WERE "fine" OR if hydration is changing (processed != total)
		else if(alpha == 0 && (state != THIRST_STATE_FINE || abs(hydration - thirsty?.water_level) >= 1))
			if(instant)
				alpha = 255
			else
				animate(src, alpha = 255, time = 1 SECONDS)

	if(old_state != state)
		if(state == THIRST_STATE_STARVING)
			if(!get_filter("thirst_outline"))
				add_filter("thirst_outline", 1, list("type" = "outline", "color" = "#FF0033", "alpha" = 0, "size" = 2))
				animate(get_filter("thirst_outline"), alpha = 200, time = 1.5 SECONDS, loop = -1)
				animate(alpha = 0, time = 1.5 SECONDS)
		else if(get_filter("thirst_outline"))
			remove_filter("thirst_outline")

		// Update color of the drink icon
		if((state == THIRST_STATE_FAT) != (old_state == THIRST_STATE_FAT))
			underlays -= food_image
			food_image.color = state == THIRST_STATE_FAT ? COLOR_DARK : null
			underlays += food_image

	// Update thirst bar
	if(old_hydration != hydration)
		thirst_bar.update_fullness(hydration, alpha == 0 || instant)

/atom/movable/screen/thirst_bar
	icon_state = "hungerbar_bar"
	screen_loc = ui_thirst
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE
	/// Mask
	VAR_PRIVATE/static/icon/bar_mask
	/// Gradient used to color the bar
	VAR_PRIVATE/static/list/thirst_gradient = list(
		0.0, "#FF0000",
		0.2, "#FF8000",
		0.4, "#f0f000",
		0.6, "#00FF00",
		0.8, "#46daff",
		1.0, "#2A72AA",
		1.2, "#494949",
	)
	/// Offset of the mask
	VAR_PRIVATE/bar_offset
	/// Last water level value (rounded) we used to update the bar
	VAR_PRIVATE/last_water_band = -1

/atom/movable/screen/thirst_bar/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/atom/movable/movable_loc = ismovable(loc) ? loc : null
	screen_loc = movable_loc?.screen_loc
	bar_mask ||= icon(icon, "hungerbar_mask")

/atom/movable/screen/thirst_bar/proc/update_fullness(new_water_level, instant)
	new_water_level = round(new_water_level / THIRST_LEVEL_FULL, 0.05)
	if(new_water_level == last_water_band)
		return
	last_water_band = new_water_level

	// Update color
	var/new_color = gradient(thirst_gradient, clamp(new_water_level, 0, 1.2))
	if(instant)
		color = new_color
	else
		animate(src, color = new_color, 0.5 SECONDS)

	// Update mask
	var/old_bar_offset = bar_offset
	bar_offset = clamp(-20 + (20 * new_water_level), -20, 0)
	if(old_bar_offset != bar_offset)
		if(instant || isnull(old_bar_offset))
			add_filter("thirst_bar_mask", 1, alpha_mask_filter(0, bar_offset, bar_mask))
		else
			transition_filter("thirst_bar_mask", alpha_mask_filter(0, bar_offset), 0.5 SECONDS)
