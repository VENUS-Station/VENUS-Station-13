/* DISABLE
/**
 * MODULAR VENUS: Component for items that belong in a Hilbert's Hotel room
 *
 * These items will show a special description and won't be allowed to leave the hotel room
 */
/datum/component/hotel_item
	/// The room number this item belongs to
	var/room_number

/datum/component/hotel_item/Initialize(room_number)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.room_number = room_number

/datum/component/hotel_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/hotel_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/**
 * Adds a special description to the item when examined - ensures it appears at the end
 */
/datum/component/hotel_item/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It feels like it <b>belongs</b> here.")

/**
 * Checks if the user can leave with this item
 * Returns FALSE if they can't leave with it
 */
/datum/component/hotel_item/proc/can_leave_with_item()
	return FALSE

/**
 * Override Initialize to automatically add the hotel_item component to items created in hotel rooms
 * This ensures crafted/deconstructed items still maintain the hotel property
 */
/obj/item/Initialize(mapload)
	. = ..()
	var/area/current_area = get_area(src)
	if(istype(current_area, /area/misc/hilbertshotel))
		var/area/misc/hilbertshotel/hotel_area = current_area
		if(hotel_area.room_number && !GetComponent(/datum/component/hotel_item))
			if(!(SShilbertshotel.lore_room_spawned && hotel_area.room_number == SShilbertshotel.hhMysteryroom_number))
				AddComponent(/datum/component/hotel_item, hotel_area.room_number)
*/
