// I am not creative with this.
/datum/language/avian
	name = "Avian"
	desc = "A collection of bird songs and calls, mostly pleasant to human ears."
	speech_verb = "chirps"
	ask_verb = "chirps curiously"
	exclaim_verb = "chirps loudly"
	whisper_verb = "coos"
	key = "a"
	space_chance = 42
	syllables = list("cheep", "peep", "beep")
	default_priority = 70
	flags = TONGUELESS_SPEECH

	icon_state = "birb"
	icon = 'modular_splurt/icons/misc/language.dmi'
	restricted = FALSE
