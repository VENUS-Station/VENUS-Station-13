///Machinery that block nebulas. This type is for convenience, you can set nebula shielding on other objects as well using add_to_nebula_shielding()
/obj/machinery/nebula_shielding
	density = TRUE

	icon = 'icons/obj/machines/nebula_shielding.dmi'
	pixel_x = -16

	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE

	///Strength of the shield we apply
	var/shielding_strength
	///The type of nebula that we shield against
	var/nebula_type
	///How much power we use every time we block the nebula's effects
	var/power_use_per_block = BASE_MACHINE_ACTIVE_CONSUMPTION * 2
	///State we use when actively blocking a nebula
	var/active_icon_state
	/// State for when we're broken and wont work anymore. Make sure to also set integrity_failure for this to work
	var/broken_icon_state

/obj/machinery/nebula_shielding/Initialize(mapload)
	. = ..()

	add_to_nebula_shielding(src, nebula_type, PROC_REF(get_nebula_shielding))

///Nebula is asking us how strong we are. Return our shield strength is all is well
/obj/machinery/nebula_shielding/proc/get_nebula_shielding()
	if(panel_open || (machine_stat & BROKEN))
		return
	if(!powered())
		update_appearance(UPDATE_ICON_STATE)
		return

	use_power_from_net(power_use_per_block)
	generate_reward()

	update_appearance(UPDATE_ICON_STATE)

	return shielding_strength

///Generate a resource for defending against the nebula
/obj/machinery/nebula_shielding/proc/generate_reward()
	return

/obj/machinery/nebula_shielding/update_icon_state()
	. = ..()

	if((machine_stat & BROKEN) && broken_icon_state)
		icon_state = broken_icon_state
	else if(!powered())
		icon_state = initial(icon_state)
	else
		icon_state = active_icon_state

///Short-lived nebula shielding sent by centcom in-case there hasn't been shielding for a while
/obj/machinery/nebula_shielding/emergency
	density = TRUE
	anchored = FALSE //so some handsome rogue could potentially move it off the station z-level
	shielding_strength = 999 //should block the nebula completely

	///How long we work untill we self-destruct
	var/detonate_in = 10 MINUTES

/obj/machinery/nebula_shielding/emergency/Initialize(mapload)
	. = ..()

	addtimer(CALLBACK(src, PROC_REF(self_destruct)), detonate_in)

///We don't live for very long, so self-destruct
/obj/machinery/nebula_shielding/emergency/proc/self_destruct()
	explosion(src, light_impact_range = 5, flame_range = 3, explosion_cause = src)
	qdel(src)

/obj/machinery/nebula_shielding/emergency/examine(mob/user)
	. = ..()

	. += span_notice("[p_They()] will block the nebula for [round(detonate_in / (1 MINUTES))] minute\s with a shield strength of [shielding_strength].")

/obj/machinery/nebula_shielding/emergency/get_nebula_shielding()
	return shielding_strength //no strings attached, we will always produce shielding

/obj/machinery/nebula_shielding/emergency/generate_reward()
	return //no reward for you

///We shield against the radioactive nebula and passively generate tritium
/obj/machinery/nebula_shielding/radiation
	name = "radioactive nebula shielder"
	desc = "Generates a field around the station, protecting it from a radioactive nebula."

	icon_state = "radioactive_shielding"
	active_icon_state = "radioactive_shielding_on"
	broken_icon_state = "radioactive_shielding_broken"

	circuit = /obj/item/circuitboard/machine/radioactive_nebula_shielding

	nebula_type = /datum/station_trait/nebula/hostile/radiation
	shielding_strength = 4

	integrity_failure = 0.4

/obj/machinery/nebula_shielding/radiation/examine(mob/user)
	. = ..()

	// . += span_notice("Passively generates tritium. Provides [shielding_strength] levels of nebula shielding when active.") //VENUS REMOVAL
	//VENUS ADDITION START - Show diagnostic information
	var/datum/station_trait/nebula/hostile/radiation/nebula = locate(/datum/station_trait/nebula/hostile/radiation) in SSstation.station_traits
	var/max_intensity = (/datum/station_trait/nebula/hostile/radiation::maximum_nebula_intensity) / (/datum/station_trait/nebula/hostile/radiation::intensity_increment_time)
	var/gg_shield = /obj/machinery/gravity_generator/main::radioactive_nebula_shielding
	var/current_total = nebula ? nebula.get_shielding_level() : gg_shield
	var/required_shields = ceil((max_intensity - gg_shield) / shielding_strength)

	. += span_notice("The diagnostic panel reads: Collective Output: [current_total] shielding levels.")
	. += span_notice("Peak Nebula Intensity: [max_intensity] total levels.")
	var/status_text = current_total >= max_intensity ? span_green("TOTAL MITIGATION ACHIEVED") : span_danger("RADIATION LEAK DETECTED - ACQUIRE MORE SHIELDING UNITS")
	. += span_notice("STATION_STATUS: [status_text]")
	. += span_notice("ESTIMATE: [required_shields] total unit\s (plus gravity generator) are required to fully block the nebula at its peak.")
	//VENUS ADDITION END
/obj/machinery/nebula_shielding/radiation/generate_reward()
	//VENUS REMOVAL START - Remove Radioactive Nebula tritium generation
	/*
	var/turf/open/turf = get_turf(src)
	if(isopenturf(turf))
		turf.atmos_spawn_air("[GAS_TRITIUM]=1;[TURF_TEMPERATURE(T20C)]")
	*/
	//VENUS REMOVAL END

/obj/machinery/nebula_shielding/radiation/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(default_deconstruction_screwdriver(user, initial(icon_state) + "_open", initial(icon_state), item))
		return

	if(default_deconstruction_crowbar(item))
		return

	return ..()

///Emergency shielding so people aren't permanently in a radstorm if shit goes very wrong in engineering
/obj/machinery/nebula_shielding/emergency/radiation
	name = "emergency nebula radiation shielder"
	desc = "Generates a field around the station to protect it from a radioactive nebula."

	icon = 'icons/obj/machines/engine/other.dmi'
	icon_state = "portgen1_1"
	pixel_x = 0

	nebula_type = /datum/station_trait/nebula/hostile/radiation

/obj/machinery/nebula_shielding/emergency/radiation/self_destruct()
	var/turf/open/turf = get_turf(src)
	if(isopenturf(turf))
		turf.atmos_spawn_air("[GAS_TRITIUM]=50;[TURF_TEMPERATURE(T20C)]") //causes a small tritium fire when combined with the explosion

	..()

//VENUS EDIT START
/* ORIGINAL:
/// Small explanation for engineering on how to set-up the radioactive nebula shielding
/obj/item/paper/fluff/radiation_nebula
	name = "radioactive nebula shielding"
	default_raw_text = {"EXTREME IMPORTANCE!!!! <br>
		Set up these radioactive nebula shielding units before the gravity generator's native shielding is overwhelmed! <br>
		Shielding units passively generate tritium, so make sure to properly ventilate/isolate the area before setting up a shielding unit!
		More circuit boards can be ordered through cargo. Consider setting up auxiliary shielding units in-case of destruction, power loss or sabotage.
	"}
*/

/// Small explanation for engineering on how to set-up the radioactive nebula shielding
/obj/item/paper/fluff/radiation_nebula
	name = "radioactive nebula shielding"
	default_raw_text = {"EXTREME IMPORTANCE!!!! <br>
		Set up these radioactive nebula shielding units before the gravity generator's native shielding is overwhelmed! <br>
		At peak intensity, the station requires 10 levels of shielding. The gravity generator provides 4, and each of these units provide 4.
		More circuit boards can be ordered through cargo. Consider setting up auxiliary shielding units in-case of destruction, power loss or sabotage.
	"}
//VENUS EDIT END

/// Warns medical that they can't use radioactive resonance
/obj/item/paper/fluff/radiation_nebula_virologist
	name = "radioactive resonance"
	default_raw_text = {"EXTREME IMPORTANCE!!!! <br>
		During routine blood screening on employees working within the nebula, we have found no traces of the symptom called 'Radioactive Resonance'. <br>
		Something inside the nebula is interfering with it; be wary of a more shallow viral genepool.
	"}
