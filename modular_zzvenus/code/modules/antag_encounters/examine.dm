/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(!client)
		return
	if(!can_view_encounter_pref(user, src))
		return
	var/encounter_pref = get_effective_encounter_pref(src)
	var/pref_text = encounter_pref_to_text(encounter_pref)
	var/pref_color = encounter_pref_to_color(encounter_pref)
	var/pref_label = "<b><font color='[pref_color]'>[pref_text]</font></b>"
	var/pref_tooltip
	switch (encounter_pref)
		if (ENCOUNTER_PREF_GREEN)
			pref_tooltip = "GREEN: Non-lethal only (thefts, stuns, kidnapping). No killing or round removal."
		if (ENCOUNTER_PREF_AMBER)
			pref_tooltip = "AMBER: Lethal allowed, but body must remain recoverable for revival."
		if (ENCOUNTER_PREF_RED)
			pref_tooltip = "RED: High stakes. Gibbing/spacing/round removal allowed."
		else
			pref_tooltip = "GREEN: Non-lethal only (thefts, stuns, kidnapping). No killing or round removal."
	. += span_info("Antagonist Encounters: [span_tooltip(pref_tooltip, pref_label)]")
