/datum/preference/choiced/antagonist_encounters
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "antagonist_encounters"
	can_randomize = FALSE

/datum/preference/choiced/antagonist_encounters/init_possible_values()
	return list(ENCOUNTER_PREF_GREEN, ENCOUNTER_PREF_AMBER, ENCOUNTER_PREF_RED)

/datum/preference/choiced/antagonist_encounters/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		"[ENCOUNTER_PREF_GREEN]" = "GREEN",
		"[ENCOUNTER_PREF_AMBER]" = "AMBER",
		"[ENCOUNTER_PREF_RED]" = "RED",
	)
	return data

/datum/preference/choiced/antagonist_encounters/create_default_value()
	return ENCOUNTER_PREF_GREEN

/datum/preference/choiced/antagonist_encounters/create_informed_default_value(datum/preferences/preferences)
	if (!preferences?.savefile)
		return ENCOUNTER_PREF_GREEN

	var/default_slot = preferences.savefile.get_entry("default_slot")
	if (!default_slot)
		default_slot = preferences.default_slot || 1

	var/list/character_data = preferences.savefile.get_entry("character[default_slot]")
	if (islist(character_data) && ("be_round_removed" in character_data))
		return character_data["be_round_removed"] ? ENCOUNTER_PREF_RED : ENCOUNTER_PREF_AMBER

	return ENCOUNTER_PREF_GREEN

/datum/preference/choiced/antagonist_encounters/apply_to_client_updated(client/client, value)
	..()
	if (!client)
		return

	var/green_label = span_green(span_bold("GREEN"))
	var/amber_label = span_yellow(span_bold("AMBER"))
	var/red_label = span_danger(span_bold("RED"))
	var/pref_label
	switch (value)
		if (ENCOUNTER_PREF_GREEN)
			pref_label = green_label
		if (ENCOUNTER_PREF_AMBER)
			pref_label = amber_label
		if (ENCOUNTER_PREF_RED)
			pref_label = red_label
		else
			pref_label = green_label

	var/list/lines = list(
		span_bold("Antagonist Encounters set to:") + " " + pref_label,
		"",
		green_label + ": Non-lethal only (thefts, stuns, kidnapping). No killing or round removal.",
		amber_label + ": Lethal allowed, but body must remain recoverable for revival.",
		red_label + ": High stakes. Gibbing/spacing/round removal allowed.",
		"",
		span_bold("Note:") + " Command, Security, and the AI are forced to AMBER+ by default.",
		span_bold("Optional:") + " You can LOOCly opt-in to higher stakes (including lethal/round removal) for an encounter or ERP."
	)
	var/message = jointext(lines, "<br>")
	to_chat(client, span_notice(message))
	get_effective_encounter_pref(client.mob, notify = TRUE)

/proc/encounter_pref_to_text(value)
	switch (value)
		if (ENCOUNTER_PREF_GREEN)
			return "GREEN"
		if (ENCOUNTER_PREF_AMBER)
			return "AMBER"
		if (ENCOUNTER_PREF_RED)
			return "RED"
	return "GREEN"

/proc/encounter_pref_to_color(value)
	switch (value)
		if (ENCOUNTER_PREF_GREEN)
			return COLOR_EMERALD
		if (ENCOUNTER_PREF_AMBER)
			return COLOR_TANGERINE_YELLOW
		if (ENCOUNTER_PREF_RED)
			return COLOR_RED
	return COLOR_EMERALD

/proc/get_effective_encounter_pref(mob/player, notify = FALSE)
	var/pref = null
	var/datum/mind/player_mind = player?.mind
	if (!isnull(player_mind?.antag_encounter_pref))
		pref = player_mind.antag_encounter_pref
	else
		pref = player?.client?.prefs?.read_preference(/datum/preference/choiced/antagonist_encounters)
		if (isnull(pref))
			pref = ENCOUNTER_PREF_GREEN

	var/needs_amber = encounter_pref_requires_amber(player)

	if (needs_amber && pref < ENCOUNTER_PREF_AMBER)
		if (notify)
			to_chat(player, span_notice("Your role forces Antagonist Encounters to at least [span_yellow("AMBER")]."))
		pref = ENCOUNTER_PREF_AMBER

	// Snapshot the effective preference for in-round use, so in-game display isn't tied to live prefs.
	if (isliving(player) && player_mind && (isnull(player_mind.antag_encounter_pref) || player_mind.antag_encounter_pref < pref))
		player_mind.antag_encounter_pref = pref

	return pref

/proc/encounter_pref_requires_amber(mob/player)
	if (isAI(player))
		return TRUE

	var/datum/job/job = player?.mind?.assigned_role
	if (job?.job_flags & JOB_HEAD_OF_STAFF)
		return TRUE
	if (job?.departments_list && (/datum/job_department/security in job.departments_list))
		return TRUE

	return FALSE

/proc/enforce_encounter_pref_min(mob/player, client/player_client = null, notify = FALSE)
	var/client/target_client = player_client || player?.client
	var/datum/preferences/preferences = target_client?.prefs
	if (!preferences)
		return

	var/current_pref = preferences.read_preference(/datum/preference/choiced/antagonist_encounters)
	if (isnull(current_pref))
		current_pref = ENCOUNTER_PREF_GREEN

	if (encounter_pref_requires_amber(player))
		if (current_pref < ENCOUNTER_PREF_AMBER)
			if (notify)
				to_chat(target_client, span_notice("Your role forces Antagonist Encounters to at least AMBER."))
		current_pref = max(current_pref, ENCOUNTER_PREF_AMBER)

	// Snapshot the preference for in-round use.
	if (player?.mind && (isnull(player.mind.antag_encounter_pref) || player.mind.antag_encounter_pref < current_pref))
		player.mind.antag_encounter_pref = current_pref

/proc/can_view_encounter_pref(mob/viewer, mob/target)
	if (!viewer || !target)
		return FALSE
	if (viewer == target)
		return TRUE
	if (viewer.client?.holder) // active admins only (deadmined should not see)
		return TRUE
	if (viewer.is_antag())
		return TRUE
	return FALSE

GLOBAL_DATUM_INIT(antag_encounter_spawn_enforcer, /datum/antag_encounter_spawn_enforcer, new)

/datum/antag_encounter_spawn_enforcer/New()
	. = ..()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_JOB_AFTER_SPAWN, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN), PROC_REF(on_job_after_spawn))

/datum/antag_encounter_spawn_enforcer/Destroy()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_JOB_AFTER_SPAWN, COMSIG_GLOB_JOB_AFTER_LATEJOIN_SPAWN))
	. = ..()

/datum/antag_encounter_spawn_enforcer/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	enforce_encounter_pref_min(spawned, player_client, notify = TRUE)
