// Define config entries for cryo
#define SUBSYSTEM_CRYO_CAN_RUN CONFIG_GET(flag/autocryo_enabled)
#define SUBSYSTEM_CRYO_TIME CONFIG_GET(number/autocryo_time_trigger)
#define MAX_CRYO_PER_TICK CONFIG_GET(number/max_cryo_per_tick)

SUBSYSTEM_DEF(auto_cryo)
	name = "Automated Cryogenics"
	flags = SS_BACKGROUND
	wait = 2 MINUTES

/datum/controller/subsystem/auto_cryo/Initialize()
	// Check config before running
	if(!SUBSYSTEM_CRYO_CAN_RUN)
		can_fire = FALSE

	return ..()

/datum/controller/subsystem/auto_cryo/fire()
	if(SUBSYSTEM_CRYO_CAN_RUN)
		cryo_mobs()

/datum/controller/subsystem/auto_cryo/proc/cryo_mobs()
	// Check for any targets
	if(!LAZYLEN(GLOB.ssd_mob_list))
		// No SSD mobs exist
		return

	// Initialize a counter for the number of mobs processed
	var/processed_mobs = 0

	// Check possible targets
	for(var/mob/living/cryo_mob in GLOB.ssd_mob_list)
		// Stop if we've hit the limit for this tick
		if(processed_mobs >= MAX_CRYO_PER_TICK)
			break

		// Get SSD time
		// This is set when disconnecting
		var/afk_time = world.time - cryo_mob.lastclienttime

		// Check if client meets the time requirement
		if(afk_time < SUBSYSTEM_CRYO_TIME)
			continue

		// Send to cryo
		cryoMob(cryo_mob, effects = TRUE)

		// Remove from SSD list
		GLOB.ssd_mob_list -= cryo_mob

		// Log cryo interaction
		log_game("[cryo_mob] was sent to cryo after being SSD for [afk_time] ticks.")

		// Increment the processed mobs counter
		processed_mobs++

// Remove defines
#undef SUBSYSTEM_CRYO_CAN_RUN
#undef SUBSYSTEM_CRYO_TIME
#undef MAX_CRYO_PER_TICK
