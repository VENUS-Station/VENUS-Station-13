/obj/effect/decal/cleanable/semendrip
	name = "semen"
	desc = null
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'modular_sand/icons/obj/genitals/effects.dmi'
	icon_state = "drip1"
	random_icon_states = list("drip1", "drip2", "drip3", "drip4")
	var/total_amount = 1

/obj/effect/decal/cleanable/semendrip/replace_decal(obj/effect/decal/cleanable/semendrip/C)
	. = ..()
	C.total_amount++
	C.transfer_blood_dna(src.blood_DNA)
	if(C.total_amount >= 10)
		var/obj/effect/decal/cleanable/semen/S = new(loc)
		S.transfer_blood_dna(C.blood_DNA)
		qdel(C)

	return TRUE

/obj/effect/decal/cleanable/milk
	name = "milk"
	desc = null
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'icons/obj/genitals/effects.dmi'
	icon_state = "milk1"
	random_icon_states = list("milk1", "milk2", "milk3", "milk4")

/obj/effect/decal/cleanable/milk/New()
	..()
	dir = pick(1,2,4,8)
	add_blood_DNA(list("Non-human DNA" = "A+"))

/obj/effect/decal/cleanable/milk/replace_decal(obj/effect/decal/cleanable/milk/S)
	if(S.blood_DNA)
		blood_DNA |= S.blood_DNA
	return ..()
