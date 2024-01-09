// Time before sending the user to cryo
/datum/config_entry/number/autocryo_time_trigger
	default = 24000
	min_val = 600
	integer = TRUE

// Should this system be used?
/datum/config_entry/flag/autocryo_enabled

// Time before deleting a disconnected ghost
/datum/config_entry/number/ghost_check_time
	default = 10 MINUTES
	min_val = 600
	integer = TRUE

// Should the system check for ghosts to delete too?
/datum/config_entry/flag/ghost_checking

// Should the system check for silicons to delete too?
/datum/config_entry/flag/silicon_checking

//Max amount of mobs cryo'd per tick
/datum/config_entry/number/max_cryo_per_tick
	default = 1
	min_val = 1
	integer = TRUE

//Max amount of mobs ghosts'd per tick
/datum/config_entry/number/max_ghosts_culled_per_tick
	default = 1
	min_val = 1
	integer = TRUE
