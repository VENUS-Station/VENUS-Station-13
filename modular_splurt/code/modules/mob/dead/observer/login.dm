/mob/dead/observer/Login()
	. = ..()

	// Check if ghost is in SSD list
	if(src in GLOB.ssd_ghost_list)
		// Remove from ghost SSD list
		GLOB.ssd_ghost_list -= src

		// Log mob ghost SSD removal
		log_game("[src] was removed from the ghost SSD list.")
        set_ghost_ssd_indicator(FALSE)
