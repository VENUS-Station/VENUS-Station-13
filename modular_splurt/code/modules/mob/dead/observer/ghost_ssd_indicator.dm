GLOBAL_DATUM_INIT(ghost_ssd_indicator, /mutable_appearance, mutable_appearance('modular_splurt/icons/mob/ghost_ssd_indicator.dmi', "default0", FLY_LAYER))

/mob/dead/observer/proc/set_ghost_ssd_indicator(state)
	if(state)
		add_overlay(GLOB.ghost_ssd_indicator)
	else
		cut_overlay(GLOB.ghost_ssd_indicator)
	return state

// Should make it so the indicator is removed if the ghost is mind-transferred to a mob
/mob/dead/observer/transfer_ckey(mob/new_mob, send_signal)
	. = ..()
	set_ghost_ssd_indicator(FALSE)
