/// Holosynth Incoming Brute damage multiplier
#define HOLOSYNTH_BRUTEMULT 3
/// Holosynth Incoming Burn damage multiplier
#define HOLOSYNTH_BURNMULT 3 //VENUS EDIT - Original: 5

/datum/species/synthetic/holosynth
	name = "Holosynth"
	id = SPECIES_HOLOSYNTH
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_CAN_STRIP,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_RADIMMUNE,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NO_HUSK,
		// TRAIT_OXYIMMUNE, VENUS REMOVAL (Doesn't exist)
		TRAIT_LITERATE,
		TRAIT_NOCRITDAMAGE, // We do our own handling of crit damage.
		TRAIT_ROBOTIC_DNA_ORGANS,
		TRAIT_HOLOSYNTH
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/synth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/synth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/synth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/synth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/synth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/synth,
	)
	exotic_bloodtype = BLOOD_TYPE_HOLOGEL
	/// Our Holographic projector that we're going to make the owner of a leash component
	var/datum/weakref/owner_projector_ref
	/// Tracks the emissive overlay glow for later deletion
	var/mutable_appearance/glow

/datum/species/synthetic/holosynth/get_default_mutant_bodyparts()
	return list(
		"ears" = list("None", FALSE),
		"tail" = list("None", FALSE),
		"ears" = list("None", FALSE),
		"legs" = list("Normal Legs", FALSE),
		"snout" = list("None", FALSE),
		MUTANT_SYNTH_ANTENNA = list("None", FALSE),
		MUTANT_SYNTH_SCREEN = list("None", FALSE),
		MUTANT_SYNTH_CHASSIS = list("Human Chassis", FALSE),
		MUTANT_SYNTH_HEAD = list("Human Head", FALSE),
	)

//Species Adding and Removal

/datum/species/synthetic/holosynth/on_species_gain(mob/living/carbon/target, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	var/mob/living/carbon/human/species_holder = target

	species_holder.physiology.brute_mod *= HOLOSYNTH_BRUTEMULT
	species_holder.physiology.burn_mod *= HOLOSYNTH_BURNMULT
	species_holder.max_grab = GRAB_PASSIVE //you're like, only half solid yk

	species_holder.AddComponent(/datum/component/glass_passer/holosynth, pass_time = 1 SECONDS, deform_glass = 0.5 SECONDS)
	species_holder.AddComponent(/datum/component/holographic_nature)
	species_holder.AddComponent(/datum/component/holosynth_effects)

	//Projector creation, leashing component found in /obj/item/holosynth_pen/Initialize(...)
	if(!isdummy(species_holder))
		var/obj/item/holosynth_pen/owner_projector = new /obj/item/holosynth_pen (get_turf(species_holder), species_holder)
		owner_projector_ref = WEAKREF(owner_projector)
		species_holder.put_in_hands(owner_projector)

/datum/species/synthetic/holosynth/on_species_loss(mob/living/carbon/target, datum/species/new_species, pref_load)
	. = ..()
	var/mob/living/carbon/human/species_holder = target
	species_holder.physiology.brute_mod /= HOLOSYNTH_BRUTEMULT
	species_holder.physiology.burn_mod /= HOLOSYNTH_BURNMULT
	species_holder.max_grab = GRAB_KILL

	var/comps_to_delete = list(
	species_holder.GetComponent(/datum/component/glass_passer/holosynth),
	species_holder.GetComponent(/datum/component/leash),
	species_holder.GetComponent(/datum/component/holographic_nature),
	species_holder.GetComponent(/datum/component/holosynth_effects)
	)
	for(var/comp in comps_to_delete)
		qdel(comp)


	var/obj/item/holosynth_pen/pen_to_unlink = owner_projector_ref?.resolve()
	if(pen_to_unlink)
		pen_to_unlink.linked_mob_ref = null

// Lore Box
/datum/species/synthetic/holosynth/get_species_lore()
	return list(\
		"Somewhere between a synthetic and a hologram, these semi-physical autonomous units are extremely vulnerable to heat and electricity. \
		A niche choice more popular among wealthy customers (silicon and uploaded organics alike) - their lack of robustness makes them somewhat inept for physical activity but they are excellent at scouting or clerical work.",

		"As of late the design of the required holoprojection equipment has shrunk considerably. \
		With an electromagnetic controller suite, hologram projection apparatus, and a ball point writing implement all fitting into the sleek pen chassis. Holosynths are traditionally once human, but any species can become a hologram."
	)

//VENUS REMOVAL START
/*
//Character creation Perks
/datum/species/synthetic/holosynth/create_pref_traits_perks()
	var/list/perks = ..() //VENUS EDIT: Make sure to inherit base unique perk descriptions - Original: var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD_ALT,
		SPECIES_PERK_NAME = "Android Aptitude",
		SPECIES_PERK_DESC = "As a synthetic lifeform, they are immune to many forms of damage humans are susceptible to. \
			Fire, cold, heat, pressure, radiation, and toxins are all ineffective against them. \
			They also can't overdose on drugs, don't need to breathe or eat, can't catch on fire, and are immune to being pierced.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_DNA,
		SPECIES_PERK_NAME = "Not Human After All",
		SPECIES_PERK_DESC = "There is no humanity behind the eyes of the synthetic, and as such, they have no DNA to genetically alter.",
	))

	return perks
	*/
//VENUS REMOVAL END

//VENUS ADDITION START
//Basically a copy/paste of the synthetic one but with modifications
/datum/species/synthetic/holosynth/create_pref_unique_perks()
	var/list/perk_descriptions = list()

	perk_descriptions += list(list( //tryin to keep traits minimal since synths will get a lot of traits when my upstream traits pr is merged
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "robot",
		SPECIES_PERK_NAME = "Synthetic Benefits",
		SPECIES_PERK_DESC = "Unlike organics, you DON'T explode when faced with a vacuum! Additionally, your chassis is built with such strength as to \
		grant you immunity to OVERpressure! Just make sure that the extreme cold or heat doesn't fry your circuitry."
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "star-of-life",
		SPECIES_PERK_NAME = "Unhuskable",
		SPECIES_PERK_DESC = "[plural_form] can't be husked, disappointing changelings galaxy-wide.",
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "robot",
		SPECIES_PERK_NAME = "Synthetic Oddities",
		SPECIES_PERK_DESC = "[plural_form] are unable to gain nutrition from traditional foods. Instead, you must either consume welding fuel or extend a \
		wire from your arm to draw power from an APC. In addition to this, welders and wires are your sutures and mesh and only specific chemicals even metabolize inside \
		of you. This ranges from whiskey, to synthanol, to various obscure medicines. Finally, you suffer from a set of wounds exclusive to synthetics."
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "music",
		SPECIES_PERK_NAME = "Tone Synthesizer",
		SPECIES_PERK_DESC = "[plural_form] can sing musical tones using an internal synthesizer.",
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "band-aid",
		SPECIES_PERK_NAME = "Extreme Structural Damage",
		SPECIES_PERK_DESC = "[plural_form] are EXTREMELY weak to blunt and burn damage (3x more damage received).",
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_MAGNIFYING_GLASS,
		SPECIES_PERK_NAME = "Translucency",
		SPECIES_PERK_DESC = "Holosynths can pass through glass, though they'll leave any physical items behind in their passage.",
	))
	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_NOTES_MEDICAL,
		SPECIES_PERK_NAME = "Regenerator",
		SPECIES_PERK_DESC = "Being made of soft-light, their projector and controller will mend tears in their form and hologel.",
	))

	return perk_descriptions
//VENUS ADDITION END

//VENUS REMOVAL START - This was copied from androids
/*
/datum/species/synthetic/holosynth/create_pref_unique_perks()
	var/list/perks = list()
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = FA_ICON_SHIELD_HEART,
		SPECIES_PERK_NAME = "Some Components Optional",
		SPECIES_PERK_DESC = "Synthetics have very few internal organs. While they can survive without many of them, \
			they don't have any benefits from them either.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_ROBOT,
		SPECIES_PERK_NAME = "Synthetic",
		SPECIES_PERK_DESC = "Being synthetic, they are vulnernable to EMPs.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_MAGNIFYING_GLASS,
		SPECIES_PERK_NAME = "Translucency",
		SPECIES_PERK_DESC = "Holosynths can pass through glass, though you'll leave any physical items behind.",
	))
	perks += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = FA_ICON_NOTES_MEDICAL,
		SPECIES_PERK_NAME = "Regenerator",
		SPECIES_PERK_DESC = "Being made of light, your projector and controller will mend tears in your form and aerogel.",
	))
	return perks
*/
//VENUS REMOVAL END

/datum/species/synthetic/holosynth/get_species_description()
	//VENUS EDIT: We use list(), we can't return a string directly (it crashes TGUI) due to some upstream species code
	return list("Holosynths are a subtype of machines; they're made of soft-light, only semi-solid and dependent on a projection device.")

/datum/species/synthetic/holosynth/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	human_for_preview.set_haircolor("#CCECFF", update = FALSE)
	human_for_preview.set_hairstyle("Mia", update = TRUE)
	human_for_preview.eye_color_left = "#66CCFF"
	human_for_preview.eye_color_right = "#66CCFF"
	regenerate_organs(human_for_preview)
	human_for_preview.update_body(is_creating = TRUE)

/mob/living/carbon/human/species/holosynth
	race = /datum/species/synthetic/holosynth

#undef HOLOSYNTH_BRUTEMULT
#undef HOLOSYNTH_BURNMULT
