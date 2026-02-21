/// VENUS PRIVATE MODULE - Damage-based blood overlay for non-carbon mobs

/// Helper proc to get blood type based on mob_biotypes for overlay purposes
/mob/living/proc/get_bloodtype_for_overlay()
	RETURN_TYPE(/datum/blood_type)
	if (!(mob_biotypes & MOB_ORGANIC))
		if (mob_biotypes & MOB_ROBOTIC)
			return get_blood_type(BLOOD_TYPE_OIL)
		return

	if (mob_biotypes & MOB_SLIME)
		return get_blood_type(BLOOD_TYPE_TOX)
	else if (mob_biotypes & MOB_PLANT)
		return get_blood_type(BLOOD_TYPE_H2O)
	else if (mob_biotypes & MOB_REPTILE)
		return get_blood_type(BLOOD_TYPE_LIZARD)
	else if (mob_biotypes & MOB_HUMANOID)
		return get_blood_type(BLOOD_TYPE_O_PLUS)

	return get_blood_type(BLOOD_TYPE_ANIMAL)

/mob/living/proc/get_damage_blood_overlay()
	// Calculate health percentage (0 to 1, where 0 = dead, 1 = full health)
	var/health_percentage = health / maxHealth

	// Only show overlay if health is below 90% (at least 10% health lost)
	if(health_percentage >= 0.9)
		return

	// Calculate damage percentage (how hurt they are, 0 to 1)
	var/damage_percentage = 1 - health_percentage

	var/datum/blood_type/blood_type = get_bloodtype_for_overlay()
	if(!blood_type)
		return

	var/scale_factor_x = get_cached_width() / ICON_SIZE_X
	var/scale_factor_y = get_cached_height() / ICON_SIZE_Y

	var/mutable_appearance/blood_overlay = mutable_appearance('modular_zzvenus/icons/effects/blood.dmi', "damageblood", appearance_flags = RESET_COLOR)
	blood_overlay.transform = blood_overlay.transform.Scale(scale_factor_x, scale_factor_y)
	blood_overlay.blend_mode = BLEND_INSET_OVERLAY
	if(iscarbon(src) && has_dna())
		blood_overlay.color = blood_type.get_damage_color(src)
	else
		blood_overlay.color = blood_type.get_color()

	// Scale alpha based on damage percentage (more damage = more visible)
	var/normalized_damage = clamp((damage_percentage - 0.1) / 0.9, 0, 1)
	blood_overlay.alpha = clamp(100 + (normalized_damage * 130), 100, 230)

	var/emissive_alpha = blood_type.get_emissive_alpha(src, is_worn = TRUE)
	if(emissive_alpha)
		var/mutable_appearance/emissive_overlay = emissive_appearance('modular_zzvenus/icons/effects/blood.dmi', "damageblood", src, alpha = emissive_alpha, effect_type = EMISSIVE_NO_BLOOM)
		emissive_overlay.transform = emissive_overlay.transform.Scale(scale_factor_x, scale_factor_y)
		emissive_overlay.blend_mode = BLEND_INSET_OVERLAY
		emissive_overlay.alpha = blood_overlay.alpha
		blood_overlay.overlays += emissive_overlay

	return blood_overlay

/// Updates the damage-based blood overlay for non-carbon mobs
/mob/living/proc/update_damage_blood_overlay()
	if(iscarbon(src))
		return

	var/health_percentage = health / maxHealth
	if(health_percentage >= 0.9)
		if(damage_blood_overlay)
			cut_overlay(damage_blood_overlay)
			damage_blood_overlay = null
			if(!(initial(appearance_flags) & KEEP_TOGETHER))
				src.appearance_flags &= ~KEEP_TOGETHER
		return

	if(damage_blood_overlay)
		cut_overlay(damage_blood_overlay)
		damage_blood_overlay = null
		if(!(initial(appearance_flags) & KEEP_TOGETHER))
			src.appearance_flags &= ~KEEP_TOGETHER

	var/mutable_appearance/blood_overlay = get_damage_blood_overlay()

	if(blood_overlay)
		src.appearance_flags |= KEEP_TOGETHER
		damage_blood_overlay = blood_overlay
		add_overlay(blood_overlay)

/// Make mobs shake when they take damage
/mob/living/proc/impact_shake(damage = 0)
	// Only trigger shake on actual damage > 0
	if(damage <= 0)
		return
	var/shake_intensity = 1
	var/shake_duration = 0.15 SECONDS
	Shake(pixelshiftx = shake_intensity, pixelshifty = shake_intensity, duration = shake_duration)
