/obj/structure/dresser/shadow
	desc = "A nicely-crafted shadow wood dresser."
	icon = 'modular_splurt/icons/obj/station_obj.dmi'
	icon_state = "dresser_shadow"

/obj/structure/dresser/mushroom
	desc = "A nicely-crafted mushroom dresser. It's filled with lots of undies."
	icon = 'modular_splurt/icons/obj/station_obj.dmi'
	icon_state = "dresser_mushwood"

// EMPTY DRESSER:

/obj/structure/dresser/empty
    // This is an empty dresser that does not generate any contents on mapload.

/obj/structure/dresser/empty/Initialize(mapload)
    . = ..()

/obj/structure/dresser/empty/generate_underwear()
    // Override the generate_underwear proc to do nothing for the empty dresser.
    return
