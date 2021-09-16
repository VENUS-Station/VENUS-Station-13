/obj/item/integrated_circuit/input/card_reader
	name = "ID card reader" //To differentiate it from the data card reader
	desc = "A circuit that can read the registred name, assignment, and PassKey string from an ID card."
	icon_state = "card_reader"

	complexity = 4
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	outputs = list(
		"registered name" = IC_PINTYPE_STRING,
		"assignment" = IC_PINTYPE_STRING,
		"passkey" = IC_PINTYPE_STRING
	)
	activators = list(
		"on read" = IC_PINTYPE_PULSE_OUT
	)

	var/cipherkey

/obj/item/integrated_circuit/input/card_reader/Initialize()
	cipherkey = uppertext(random_string(2000+rand(0,10), GLOB.alphabet)) // the same way SScircuit.cipherkey is generated
	..()

/obj/item/integrated_circuit/input/card_reader/attackby_react(obj/item/I, mob/living/user, intent)
	var/obj/item/card/id/card = I.GetID()
	var/list/access = I.GetAccess()
	var/passkey = strtohex(XorEncrypt(json_encode(access), cipherkey))

	if(assembly)
		assembly.access_card.access |= access

	if(card) // An ID card.
		set_pin_data(IC_OUTPUT, 1, card.registered_name)
		set_pin_data(IC_OUTPUT, 2, card.assignment)

	else if(length(access))	// A non-card object that has access levels.
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)

	else
		return FALSE

	set_pin_data(IC_OUTPUT, 3, passkey)

	push_data()
	activate_pin(1)
	return TRUE

/obj/item/integrated_circuit/input/card_reader/set_pin_data(pin_type, pin_number, datum/new_data)
	cipherkey = uppertext(random_string(2000+rand(0,10), GLOB.alphabet)) // NEVER REUSE THE SAME KEY
