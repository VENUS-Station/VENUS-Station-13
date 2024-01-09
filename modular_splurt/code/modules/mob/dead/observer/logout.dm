/mob/dead/observer/Logout()
	. = ..()

	lastclienttime = world.time

	// Add to SSD list
	GLOB.ssd_ghost_list |= src

	// Log mob SSD status
	log_game("[src] was added to the ghost SSD list.")
	set_ssd_indicator(TRUE)
