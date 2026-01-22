/*
/datum/supply_pack/imports/lmg
	name = "Smuggled Sol Light Machinegun Crate"
	desc = "(*!&@#GOOD NEWS, OPERATIVE! WE GOT YOU THE BIG LEAGUE AUTOMATIC WEAPONS. BY \
		SMUGGLING THIS CRATE THROUGH A FEW OUTDATED CUSTOMS CHECKPOINTS, WE'VE THE NEXT BEST THING! \
		A FUCKING LIGHT MACHINE GUN. DON'T WORRY, THE RUMORS ABOUT THE GUN MELTING YOU ARE JUST THAT! RUMORS! \
		THESE THINGS WORK FINE! MIGHT BE SLIGHTLY DIRTY.!#@*$"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 52
	contains = list(
		/obj/item/gun/ballistic/automatic/sol_rifle/machinegun = 1,
		/obj/item/ammo_box/magazine/c40sol_rifle/drum = 2,
	)
*/ //BUBBER EDIT: IT'S AS BAD AS YOU THOUGHT

//Goodies

//Override
/datum/supply_pack/security/ammo
	contains = list(/obj/item/ammo_box/advanced/s12gauge/bean = 3,
					/obj/item/ammo_box/advanced/s12gauge/rubber = 3,
					/obj/item/ammo_box/speedloader/c38/trac,
					/obj/item/ammo_box/speedloader/c38/hotshot,
					/obj/item/ammo_box/speedloader/c38/iceblox,
				)
	special = FALSE

//This makes the Security ammo crate use the cool advanced ammo boxes instead of the old ones

//VENUS ADDITION START - Re-added modular laser rifles and carbines to cargo (inspired by Nova Sector)
/datum/supply_pack/security/armory/short_mod_laser
	name = "Modular Laser Carbine Crate"
	desc = "One 'Hoshi' modular laser carbine, a compact energy weapon that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle/carbine,
	)
	crate_name = "\improper Modular Laser Carbine Crate"

/datum/supply_pack/security/armory/big_mod_laser
	name = "Modular Laser Rifle Crate"
	desc = "One 'Hyeseong' modular laser rifle, a bulky energy weapon that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle,
	)
	crate_name = "\improper Modular Laser Rifle Crate"
//VENUS ADDITION END
