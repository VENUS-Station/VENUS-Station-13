//OVERRIDES

/datum/supply_pack/security/ammo

/datum/supply_pack/security/armory/ballistic
	name = "Peacekeeper Combat Shotguns Crates"
	contains = list(/obj/item/gun/ballistic/shotgun/automatic/combat = 3,
					/obj/item/storage/pouch/ammo = 3,
					/obj/item/storage/belt/bandolier = 3)

//The price seems silly but do understand that ballistic should  be as restricted as possible
//We should prioritise the availability and viability of energy weapon first and foremost


/datum/supply_pack/goody/energy_single
	name = "Energy Gun Single-Pack"
	desc = "Contains one energy gun, capable of firing both nonlethal and lethal blasts of light."
	cost = PAYCHECK_COMMAND * 6
	access_view = ACCESS_WEAPONS
	contains = list(/obj/item/gun/energy/e_gun)

/datum/supply_pack/goody/laser_single
	name = "Laser Gun Single-Pack"
	desc = "Contains one laser gun, the lethal workhorse of Nanotrasen security everywehere."
	cost = PAYCHECK_COMMAND * 3
	access_view = ACCESS_WEAPONS
	contains = list(/obj/item/gun/energy/laser)

//VENUS ADDITION START - Added modular laser rifles and carbines to cargo (inspired by Nova Sector)
/datum/supply_pack/security/armory/short_mod_laser
	name = "Modular Laser Carbine Crate"
	desc = "Three 'Hoshi' modular laser carbines, compact energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle/carbine = 3,
	)
	crate_name = "\improper Modular Laser Carbine Crate"

/datum/supply_pack/security/armory/big_mod_laser
	name = "Modular Laser Rifle Crate"
	desc = "Two 'Hyeseong' modular laser rifles, bulky energy weapons that can be rapidly reconfigured into different firing modes."
	cost = CARGO_CRATE_VALUE * 12
	contains = list(
		/obj/item/gun/energy/modular_laser_rifle = 2,
	)
	crate_name = "\improper Modular Laser Rifle Crate"

/datum/supply_pack/goody/modular_laser_single_carbine
	name = "Modular Laser Gun Single-Pack"
	desc = "One 'Hoshi' modular laser carbine, a compact energy weapon that can be rapidly reconfigured into different firing modes."
	cost = PAYCHECK_COMMAND * 8
	access_view = ACCESS_WEAPONS
	contains = list(/obj/item/gun/energy/modular_laser_rifle/carbine)

/datum/supply_pack/goody/modular_laser_single_rifle
	name = "Modular Laser Rifle Single-Pack"
	desc = "One 'Hyeseong' modular laser rifle, a bulky energy weapon that can be rapidly reconfigured into different firing modes."
	cost = PAYCHECK_COMMAND * 12
	access_view = ACCESS_WEAPONS
	contains = list(/obj/item/gun/energy/modular_laser_rifle)
//VENUS ADDITION END

/datum/supply_pack/security/armory/ionrifle
	name = "Ion Carbine Crate"
	cost = CARGO_CRATE_VALUE * 18 //Same as the energy gun crate
	desc = "Contains two Ion Carbines, for when you need to deal with speedy space tiders, mechs, or upstart silicons."
	contains = list(/obj/item/gun/energy/ionrifle/carbine = 2)
	crate_name = "Ion Carbine Crate"

/datum/supply_pack/security/miniegun
	name = "Mini E-Gun Bulk Crate"
	cost = CARGO_CRATE_VALUE * 2
	desc = "Contains three mini e-guns, cheap and semi-effective, for when you need to arm up on a budget."
	contains = list(/obj/item/gun/energy/e_gun/mini = 3)
	crate_name = "Mini E-Gun Bulk Crate"
//You know the problem is literally nobody want to buy the mini-egun even if it was cheap
