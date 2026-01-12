/datum/quirk/dormant_healing_factor
	name = "Dormant Healing Factor"
	desc = "Most people's bodies heal light injuries when sleeping, but your body is capable of mending even more severe wounds and internal damage when in deep sleep. You best get yourself a comfy bed, a dark room, and hope nobody stabs you while you're dreamin'."
	value = 8
	gain_text = span_notice("You feel an instinctive stillness - like your body is preparing for nocturnal repair.")
	lose_text = span_notice("The stillness is gone; your body no longer feels primed to mend itself during sleep.")
	medical_record_text = "Subject demonstrates sleep-dependent enhancement of tissue repair consistent with exaggerated slow-wave (NREM) restorative physiology; recovery kinetics exceed baseline."
	species_blacklist = list(SPECIES_PODPERSON_WEAK,)
	mob_trait = TRAIT_DORMANT_HEALING_FACTOR
	hardcore_value = -6
	icon = FA_ICON_BRIEFCASE_MEDICAL
