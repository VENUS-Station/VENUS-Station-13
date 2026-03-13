/// VENUS EVENT: REVERT ON 16/03, whatevre idc Biohazard Infestation - Always spawns 5 mold cores on round start
#define MOLDIES_SPAWN_COUNT 5

/datum/round_event_control/mold
	name = "Moldies"
	description = "A mold outbreak on the station. The mold will spread across the station if not contained."
	typepath = /datum/round_event/mold
	max_occurrences = 3
	earliest_start = 0
	min_players = 0
	category = EVENT_CATEGORY_ENTITIES

/datum/round_event/mold
	fakeable = FALSE
	announce_when = 120 // 4 minutes
	announce_chance = 0

/datum/round_event/mold/announce(fake)
	if(!fake)
		INVOKE_ASYNC(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, minimum_security_level), SEC_LEVEL_VIOLET, FALSE, FALSE)

	priority_announce("Confirmed outbreak of level 6 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", ANNOUNCER_OUTBREAK6)

/datum/round_event/mold/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas
	var/mold_spawns = MOLDIES_SPAWN_COUNT

	var/obj/structure/mold/resin/test/test_resin = new()

	var/list/possible_spawn_areas = typecacheof(typesof(/area/station/maintenance, /area/station/security/prison, /area/station/construction))

	for(var/area/checked_area as anything in GLOB.areas)
		if(!is_station_level(checked_area.z))
			continue

		if(!is_type_in_typecache(checked_area, possible_spawn_areas))
			continue

		for (var/list/zlevel_turfs as anything in checked_area.get_zlevel_turf_lists())
			for(var/turf/area_turf as anything in zlevel_turfs)
				if(isopenspaceturf(area_turf))
					continue

				if(!area_turf.Enter(test_resin))
					continue

				if(locate(/turf/closed) in range(2, area_turf))
					continue

				turfs += area_turf

	qdel(test_resin)

	for(var/i in 1 to mold_spawns)
		var/list/possible_mold_types = list()

		for(var/iterated_type in subtypesof(/datum/mold_type))
			var/datum/mold_type/mold_type = new iterated_type()
			possible_mold_types += mold_type

		if(!possible_mold_types)
			log_game("Event: Moldies failed to spawn due to lack of possible types.")
			message_admins("Moldies failed to spawn due to lack of possible types.")
			break

		var/datum/mold_type/picked_type = pick(possible_mold_types)

		shuffle(turfs)
		var/turf/picked_turf = pick(turfs)
		if(length(turfs)) //Pick a turf to spawn at if we can
			if(locate(/obj/structure/mold/structure/core) in range(20, picked_turf))
				turfs -= picked_turf
				continue

			announce_chance = 100

			var/obj/structure/mold/structure/core/new_core = new (picked_turf, picked_type)
			announce_to_ghosts(new_core)
			turfs -= picked_turf
			i++
		else
			log_game("Event: Moldies failed to spawn due to lack of available turfs.")
			message_admins("Moldies failed to spawn due to lack of available turfs.")
			break

/// Auto-fires the moldies event on round start (called from SSPersistence)
/proc/spawn_moldies_on_start()
	var/datum/round_event_control/mold/event_control = new
	event_control.run_event(random = FALSE, admin_forced = TRUE)
	log_game("VENUS EVENT: Auto-fired Moldies biohazard event on round start ([MOLDIES_SPAWN_COUNT] cores)")

#undef MOLDIES_SPAWN_COUNT
