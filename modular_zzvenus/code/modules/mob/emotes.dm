/**
 * Creates a visual "ping" effect over an atom, useful for indicating sound sources
 *
 * @param atom/A The atom to show the ping effect above
 */
/proc/ping_sound(atom/A)
	var/mutable_appearance/ping_appearance = mutable_appearance('modular_zzvenus/icons/effects/effects.dmi', "emote", ABOVE_MOB_LAYER)
	if(!ping_appearance)
		return
	ping_appearance.pixel_y = 8
	A.flick_overlay_view(ping_appearance, 0.6 SECONDS)

/datum/emote/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = ..()
	var/tmp_sound = get_sound(user)
	if(tmp_sound && should_play_sound(user, intentional))
		ping_sound(user)
