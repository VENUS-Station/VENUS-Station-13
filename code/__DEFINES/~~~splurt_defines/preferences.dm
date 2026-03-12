/// Loadout simple item color (changes color var directly)
#define INFO_COLOR "color"

#define LOADOUT_FLAG_ALLOW_SIMPLE_COLOR (1<<5)


GLOBAL_LIST_INIT(announcer_type_keys, list(
		"Use Station Default" = null,
		//VENUS REMOVAL START
		/*
		// "Tibbets" = /datum/centcom_announcer/intern/tibbets,
		// "Lait" = /datum/centcom_announcer/default/lait,
		*/
		//VENUS REMOVAL END
		"Dagoth Ur" = /datum/centcom_announcer/dagoth_ur,
		"Bubber" = /datum/centcom_announcer/default,
		"TG Intern" = /datum/centcom_announcer/intern,
		"Medbot" = /datum/centcom_announcer/medbot
	))
