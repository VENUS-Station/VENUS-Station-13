// Define config entries for cryo
#define SUBSYSTEM_CRYO_CAN_RUN CONFIG_GET(flag/autocryo_enabled)
#define SUBSYSTEM_CRYO_CHECK_GHOSTS CONFIG_GET(flag/ghost_checking)
#define SUBSYSTEM_CRYO_CHECK_SILICONS CONFIG_GET(flag/silicon_checking)
#define SUBSYSTEM_CRYO_TIME CONFIG_GET(number/autocryo_time_trigger)
#define SUBSYSTEM_CRYO_GHOST_PERIOD CONFIG_GET(number/ghost_check_time)
#define MAX_CRYO_PER_TICK CONFIG_GET(number/max_cryo_per_tick)
#define MAX_GHOSTS_CULLED_PER_TICK CONFIG_GET(number/max_ghosts_culled_per_tick)

SUBSYSTEM_DEF(auto_cryo)
	name = "Automated Cryogenics"
	flags = SS_BACKGROUND
	wait = 10 MINUTES

/datum/controller/subsystem/auto_cryo/Initialize()
	// Check config before running
	if(!SUBSYSTEM_CRYO_CAN_RUN && !SUBSYSTEM_CRYO_CHECK_GHOSTS && !SUBSYSTEM_CRYO_CHECK_SILICONS)
		can_fire = FALSE

	return ..()

/datum/controller/subsystem/auto_cryo/fire()
	if(SUBSYSTEM_CRYO_CAN_RUN)
		cryo_carbon_mobs()
	if(SUBSYSTEM_CRYO_CHECK_GHOSTS)
		cull_ghosts()
	if(SUBSYSTEM_CRYO_CHECK_SILICONS)
		cryo_silicon_mobs()

/datum/controller/subsystem/auto_cryo/proc/cryo_carbon_mobs()
	// Check for any targets
	if(!LAZYLEN(GLOB.ssd_mob_list))
		// No SSD mobs exist
		return

	// Initialize a counter for the number of mobs processed
	var/processed_mobs = 0

	// Check possible targets
	for(var/mob/living/carbon/cryo_mob in GLOB.ssd_mob_list)
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

/datum/controller/subsystem/auto_cryo/proc/cryo_silicon_mobs()
	// Check for any targets
	if(!LAZYLEN(GLOB.ssd_mob_list))
		// No SSD mobs exist
		return

	// Initialize a counter for the number of mobs processed
	var/processed_silicon_mobs = 0

	// Check possible targets
	for(var/mob/living/silicon/silicon_mob in GLOB.ssd_mob_list)
		// Stop if we've hit the limit for this tick
		if(processed_silicon_mobs >= MAX_CRYO_PER_TICK)
			break

		// Get SSD time
		// This is set when disconnecting
		var/afk_time = world.time - silicon_mob.lastclienttime

		// Check if client meets the time requirement
		if(afk_time < SUBSYSTEM_CRYO_TIME)
			continue

		// Send to cryo
		cryoMob(silicon_mob, effects = TRUE)

		// Remove from SSD list
		GLOB.ssd_mob_list -= silicon_mob

		// Log cryo interaction
		log_game("Silicon [silicon_mob] was sent to cryo after being SSD for [afk_time] ticks.")

		// Increment the processed mobs counter
		processed_silicon_mobs++

/datum/controller/subsystem/auto_cryo/proc/cull_ghosts()
	// Check for any targets
	if(!LAZYLEN(GLOB.dead_mob_list))
		return
	
	// Initialize a counter for the number of ghosts processed
	var/processed_ghosts = 0

	// Check possible targets
	for(var/mob/dead/observer/ghost_mob in GLOB.dead_mob_list)
		// Stop if we've hit the limit for this tick
		if(processed_ghosts >= MAX_GHOSTS_CULLED_PER_TICK)
			break
		
		// Get SSD time
		// This is set when disconnecting
		var/afk_time = world.time - ghost_mob.lastclienttime

		// Check if client meets the time requirement
		if(afk_time < SUBSYSTEM_CRYO_GHOST_PERIOD)
			continue

		// Log del interaction
		log_game("[ghost_mob] was deleted after being SSD for [afk_time] ticks.")

		// Send to valhalla
		qdel(ghost_mob)

		// Increment the processed ghosts counter
		processed_ghosts++

// Remove defines
#undef SUBSYSTEM_CRYO_CAN_RUN
#undef SUBSYSTEM_CRYO_CHECK_GHOSTS
#undef SUBSYSTEM_CRYO_CHECK_SILICONS
#undef SUBSYSTEM_CRYO_TIME
#undef SUBSYSTEM_CRYO_GHOST_PERIOD
#undef MAX_CRYO_PER_TICK
#undef MAX_GHOSTS_CULLED_PER_TICK
