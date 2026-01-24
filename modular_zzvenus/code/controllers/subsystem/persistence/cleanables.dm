/// Base directory for persistent data
#define PERSISTENCE_BASE_DIRECTORY "data/zzvenus_persistence"
/// Directory where persistent cleanables are saved
#define CLEANABLES_DIRECTORY "[PERSISTENCE_BASE_DIRECTORY]/cleanables"
/// Directory where persistent trash is saved
#define TRASH_DIRECTORY "[PERSISTENCE_BASE_DIRECTORY]/trash"
/// Maximum number of cleanables to persist across the entire station
#define MAX_PERSISTENT_CLEANABLES 500
/// Maximum number of cleanables allowed per tile
#define MAX_CLEANABLES_PER_TILE 5
/// Maximum number of trash items to persist across the entire station
#define MAX_PERSISTENT_TRASH 200
/// Maximum number of trash items allowed per tile
#define MAX_TRASH_PER_TILE 3
/// Maximum number of limbs/organs allowed per tile
#define MAX_LIMBS_ORGANS_PER_TILE 3

/// Cleanable types that shouldn't be persisted (ephemeral or can't be reconstructed)
GLOBAL_LIST_INIT(non_persistent_cleanables, list(
	/obj/effect/decal/cleanable/blood/footprints,
	/obj/effect/decal/cleanable/blood/trail,
	/obj/effect/decal/cleanable/blood/trail_holder,
))

/// Saves all valid cleanables to a JSON file for the current map
/datum/controller/subsystem/persistence/proc/save_cleanables()
	var/list/cleanables_to_save = list()
	var/list/cleanables_by_tile = list() // Track cleanables per tile for cap

	// Get all station turfs directly (excluding maintenance)
	// Note: subtypes=TRUE is required to get all /area/station/* subtypes
	var/list/station_turfs = get_area_turfs(/area/station, subtypes=TRUE)
	for(var/turf/turf_loc as anything in station_turfs)
		// Skip maintenance areas
		var/area/turf_area = turf_loc.loc
		if(istype(turf_area, /area/station/maintenance))
			continue

		// Check all cleanables on this turf
		for(var/obj/effect/decal/cleanable/cleanable in turf_loc.contents)
			// Skip maploaded cleanables (already in the map file, would duplicate)
			if(cleanable.maploaded)
				continue

			// Skip footprints and trails (ephemeral, can't be properly reconstructed)
			if(is_type_in_list(cleanable, GLOB.non_persistent_cleanables))
				continue

			// Verify it's on a station z-level (for multi-z or edge cases)
			if(!is_station_level(turf_loc.z))
				continue

			var/tile_key = "[turf_loc.x],[turf_loc.y],[turf_loc.z]"

			// Track per-tile save count numerically to enforce cap correctly
			var/tile_saved_count = cleanables_by_tile[tile_key] || 0
			if(tile_saved_count >= MAX_CLEANABLES_PER_TILE)
				continue

			// Prepare type and color for saving
			var/persist_type = cleanable.type
			var/persist_color = cleanable.color
			var/persist_blood_color = null

			// For blood/gibs: always save as dried to preserve species/mixed blood colors
			// If fresh, compute the dried color now so we don't need DNA on load
			if(istype(cleanable, /obj/effect/decal/cleanable/blood))
				var/obj/effect/decal/cleanable/blood/blood_decal = cleanable

				// Debug: log the original color before processing

				// Only compute dried colors for blood that can actually dry (skip oil, xeno acid, etc.)
				if(blood_decal.can_dry)
					// Compute persist color from original species color where possible.
					// If already dried but no cached color exists, keep current color to avoid re-darkening.
					if(blood_decal.dried)
						if(blood_decal.cached_blood_color)
							persist_color = blood_decal.get_dried_color(blood_decal.cached_blood_color)
						else
							persist_color = blood_decal.color
					else
						var/original_color = blood_decal.cached_blood_color || blood_decal.color
						persist_color = blood_decal.get_dried_color(original_color)
				else
					// For non-drying blood (like oil), just use the current color
					persist_color = blood_decal.color

				// Capture source species color if available for future loads
				persist_blood_color = blood_decal.cached_blood_color

			// Store only visual data, no DNA/reagents/forensics
			var/list/cleanable_data = list(
				"type" = persist_type,
				"x" = turf_loc.x,
				"y" = turf_loc.y,
				"z" = turf_loc.z,
				"icon_state" = cleanable.icon_state,
				"dir" = cleanable.dir,
				"color" = persist_color,
				"name" = (cleanable.name != initial(cleanable.name)) ? cleanable.name : null,
				"pixel_x" = cleanable.pixel_x,
				"pixel_y" = cleanable.pixel_y,
				"rounds_persisted" = cleanable.rounds_persisted + 1 // Increment for next round
			)

			// Persist original species blood color when available
			if(!isnull(persist_blood_color))
				cleanable_data["blood_color"] = persist_blood_color

			// Save graffiti-specific properties
			if(istype(cleanable, /obj/effect/decal/cleanable/crayon))
				var/obj/effect/decal/cleanable/crayon/crayon_decal = cleanable
				cleanable_data["paint_colour"] = crayon_decal.paint_colour
				cleanable_data["rotation"] = crayon_decal.rotation

			cleanables_to_save += list(cleanable_data)
			cleanables_by_tile[tile_key] = tile_saved_count + 1

			// Apply total cap
			if(length(cleanables_to_save) >= MAX_PERSISTENT_CLEANABLES)
				break

	// If no cleanables to save, don't create file
	if(!length(cleanables_to_save))
		return

	// Prepare JSON structure
	var/list/json_data = list(
		"version" = 1,
		"map_name" = SSmapping.current_map?.map_name || "unknown",
		"cleanables" = cleanables_to_save
	)

	// Write to file
	var/map_name = SSmapping.current_map?.map_name || "unknown"
	var/sanitized_map_name = replacetext(map_name, " ", "_")
	var/json_file = file("[CLEANABLES_DIRECTORY]/[sanitized_map_name].json")
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json_data))

/// Loads cleanables from JSON file and spawns them on the map
/datum/controller/subsystem/persistence/proc/load_cleanables()
	var/map_name = SSmapping.current_map?.map_name
	if(!map_name)
		return

	var/sanitized_map_name = replacetext(map_name, " ", "_")
	var/json_file = file("[CLEANABLES_DIRECTORY]/[sanitized_map_name].json")
	if(!fexists(json_file))
		return // First round on this map, no data to load

	var/list/json_data = json_decode(file2text(json_file))
	if(!json_data || !islist(json_data))
		return

	var/list/cleanables_list = json_data["cleanables"]
	if(!cleanables_list || !islist(cleanables_list))
		return

	// Pre-build cache of valid areas (avoids repeated get_area + istype checks)
	var/list/valid_areas = list()
	for(var/area/area_loc as anything in GLOB.areas)
		if(istype(area_loc, /area/station) && !istype(area_loc, /area/station/maintenance))
			valid_areas[area_loc] = TRUE

	var/loaded_count = 0
	var/list/cleanables_per_tile = list() // Track spawned cleanables per tile

	for(var/list/cleanable_data in cleanables_list)
		// Early cap check to avoid unnecessary processing
		if(loaded_count >= MAX_PERSISTENT_CLEANABLES)
			break

		// Validate data structure and type
		if(!islist(cleanable_data))
			continue

		var/cleanable_type = text2path(cleanable_data["type"])
		if(!ispath(cleanable_type, /obj/effect/decal/cleanable))
			continue

		// Validate and extract coordinates
		var/x = cleanable_data["x"]
		var/y = cleanable_data["y"]
		var/z = cleanable_data["z"]

		if(!isnum(x) || !isnum(y) || !isnum(z))
			continue

		// Verify station z-level early (before locate)
		if(!is_station_level(z))
			continue

		// Get the turf
		var/turf/target_turf = locate(x, y, z)
		if(!target_turf)
			continue

		// Check if area is valid using cached list
		var/area/area_loc = target_turf.loc
		if(!valid_areas[area_loc])
			continue

		// Check per-tile cap
		var/tile_key = "[x],[y],[z]"
		var/tile_count = cleanables_per_tile[tile_key] || 0
		if(tile_count >= MAX_CLEANABLES_PER_TILE)
			continue

		// Spawn the cleanable without any DNA/reagent data
		// Note: If this is dried blood, Initialize() will call dry() which sets color from DNA (which we don't have)
		// We fix this immediately after by overwriting with our saved dried color
		var/obj/effect/decal/cleanable/new_cleanable = new cleanable_type(target_turf)
		if(!new_cleanable)
			continue

		cleanables_per_tile[tile_key] = tile_count + 1

		// Apply saved visual properties
		if(cleanable_data["icon_state"])
			new_cleanable.icon_state = cleanable_data["icon_state"]
		if(cleanable_data["dir"])
			new_cleanable.dir = cleanable_data["dir"]
		// Blood colors are applied in its own block
		if(cleanable_data["color"] && !istype(new_cleanable, /obj/effect/decal/cleanable/blood))
			new_cleanable.color = cleanable_data["color"]
		if(cleanable_data["name"])
			new_cleanable.name = cleanable_data["name"]
		// Restore rounds persisted for janitor examine
		if(!isnull(cleanable_data["rounds_persisted"]))
			new_cleanable.rounds_persisted = cleanable_data["rounds_persisted"]

		// For blood/gibs: ensure dried state is properly applied
		// The saved color is already the correct dried shade (computed from original blood color on save)
		if(istype(new_cleanable, /obj/effect/decal/cleanable/blood))
			var/obj/effect/decal/cleanable/blood/blood_decal = new_cleanable
			// Restore cached species color when present so future saves/load can recompute correctly
			if(cleanable_data["blood_color"])
				blood_decal.cached_blood_color = cleanable_data["blood_color"]
			// Only mark as dried if it can actually dry (skip oil, xeno acid, etc.)
			if(blood_decal.can_dry)
				// Ensure it's marked as dried (may already be from Initialize if type was /old)
				blood_decal.dried = TRUE
				// Stop any drying processing
				STOP_PROCESSING(SSblood_drying, blood_decal)
				// Reapply the saved dried color to override any DNA-based color from Initialize
				blood_decal.color = cleanable_data["color"]
			// Mark forensic DNA as too old to identify while preserving blood type for naming
			if(blood_decal.forensics)
				var/list/old_blood = blood_decal.forensics.blood_DNA
				var/list/new_blood = list()
				var/too_old_index = 1
				if(islist(old_blood))
					for(var/blood_key in old_blood)
						var/datum/blood_type/blood_type = old_blood[blood_key]
						if(!istype(blood_type))
							blood_type = get_blood_type(blood_type)
						if(!istype(blood_type))
							continue
						var/label = (too_old_index == 1) ? "Too old to identify" : "Too old to identify #[too_old_index]"
						new_blood[label] = blood_type
						too_old_index++
				if(!length(new_blood))
					var/datum/blood_type/fallback_type = blood_decal.get_default_blood_type()
					if(istype(fallback_type))
						new_blood["Too old to identify"] = fallback_type
				if(length(new_blood))
					blood_decal.forensics.blood_DNA = new_blood
			// Update appearance to apply dried names/descriptions and overlays
			blood_decal.update_appearance()
			// For non-drying blood, set color AFTER update_appearance to prevent darkening
			if(!blood_decal.can_dry)
				blood_decal.color = cleanable_data["color"]

		// Restore pixel offsets (important for graffiti positioning)
		if(!isnull(cleanable_data["pixel_x"]))
			new_cleanable.pixel_x = cleanable_data["pixel_x"]
		if(!isnull(cleanable_data["pixel_y"]))
			new_cleanable.pixel_y = cleanable_data["pixel_y"]

		// Restore graffiti-specific properties
		if(istype(new_cleanable, /obj/effect/decal/cleanable/crayon))
			var/obj/effect/decal/cleanable/crayon/crayon_decal = new_cleanable
			if(cleanable_data["paint_colour"])
				crayon_decal.paint_colour = cleanable_data["paint_colour"]
				crayon_decal.add_atom_colour(crayon_decal.paint_colour, FIXED_COLOUR_PRIORITY)
			if(cleanable_data["rotation"])
				crayon_decal.rotation = cleanable_data["rotation"]
				var/matrix/M = matrix()
				M.Turn(crayon_decal.rotation)
				crayon_decal.transform = M

		loaded_count++

	if(loaded_count > 0)
		log_game("Loaded [loaded_count] persistent cleanables for map '[map_name]'")

/// Saves all valid trash items to a JSON file for the current map
/datum/controller/subsystem/persistence/proc/save_trash()
	var/list/trash_to_save = list()
	var/list/trash_by_tile = list() // Track trash per tile for cap
	var/list/limbs_organs_by_tile = list() // Track limbs/organs per tile for their own cap

	// Get all station turfs directly (excluding maintenance)
	var/list/station_turfs = get_area_turfs(/area/station, subtypes=TRUE)
	for(var/turf/turf_loc as anything in station_turfs)
		// Skip maintenance areas
		var/area/turf_area = turf_loc.loc
		if(istype(turf_area, /area/station/maintenance))
			continue

		// Check all trash items on this turf
		for(var/obj/item/trash/trash_item in turf_loc.contents)
			// Skip maploaded trash (already in the map file, would duplicate)
			if(trash_item.maploaded)
				continue

			// Verify it's on a station z-level
			if(!is_station_level(turf_loc.z))
				continue

			var/tile_key = "[turf_loc.x],[turf_loc.y],[turf_loc.z]"

			// Track per-tile save count numerically to enforce cap correctly
			var/tile_saved_count = trash_by_tile[tile_key] || 0
			if(tile_saved_count >= MAX_TRASH_PER_TILE)
				continue

			// Store visual and basic data
			var/list/trash_data = list(
				"type" = trash_item.type,
				"x" = turf_loc.x,
				"y" = turf_loc.y,
				"z" = turf_loc.z,
				"icon_state" = trash_item.icon_state,
				"dir" = trash_item.dir,
				"name" = (trash_item.name != initial(trash_item.name)) ? trash_item.name : null,
				"pixel_x" = trash_item.pixel_x,
				"pixel_y" = trash_item.pixel_y,
				"rounds_persisted" = trash_item.rounds_persisted + 1 // Increment for next round
			)

			trash_to_save += list(trash_data)
			trash_by_tile[tile_key] = tile_saved_count + 1

			// Apply total cap
			if(length(trash_to_save) >= MAX_PERSISTENT_TRASH)
				break

		// Also persist limbs on this turf
		for(var/obj/item/bodypart/limb in turf_loc.contents)
			if(limb.maploaded)
				continue

			// Skip heads - we don't want to persist these
			if(istype(limb, /obj/item/bodypart/head))
				continue
			// Verify it's on a station z-level
			if(!is_station_level(turf_loc.z))
				continue

			var/tile_key = "[turf_loc.x],[turf_loc.y],[turf_loc.z]"
			var/tile_saved_count = limbs_organs_by_tile[tile_key] || 0
			if(tile_saved_count >= MAX_LIMBS_ORGANS_PER_TILE)
				continue

			var/list/item_data = list(
				"type" = limb.type,
				"x" = turf_loc.x,
				"y" = turf_loc.y,
				"z" = turf_loc.z,
				"icon_state" = limb.icon_state,
				"dir" = limb.dir,
				"name" = (limb.name != initial(limb.name)) ? limb.name : null,
				"pixel_x" = limb.pixel_x,
				"pixel_y" = limb.pixel_y,
				"rounds_persisted" = limb.rounds_persisted + 1
			)

			trash_to_save += list(item_data)
			limbs_organs_by_tile[tile_key] = tile_saved_count + 1

			if(length(trash_to_save) >= MAX_PERSISTENT_TRASH)
				break

		// Also persist organs on this turf
		for(var/obj/item/organ/organ in turf_loc.contents)
			if(organ.maploaded)
				continue

			// Skip genitals - we don't want to persist these
			if(istype(organ, /obj/item/organ/genital))
				continue

			// Verify it's on a station z-level
			if(!is_station_level(turf_loc.z))
				continue

			var/tile_key = "[turf_loc.x],[turf_loc.y],[turf_loc.z]"
			var/tile_saved_count = limbs_organs_by_tile[tile_key] || 0
			if(tile_saved_count >= MAX_LIMBS_ORGANS_PER_TILE)
				continue

			var/list/organ_item_data = list(
				"type" = organ.type,
				"x" = turf_loc.x,
				"y" = turf_loc.y,
				"z" = turf_loc.z,
				"icon_state" = organ.icon_state,
				"dir" = organ.dir,
				"name" = (organ.name != initial(organ.name)) ? organ.name : null,
				"pixel_x" = organ.pixel_x,
				"pixel_y" = organ.pixel_y,
				"rounds_persisted" = organ.rounds_persisted + 1
			)

			trash_to_save += list(organ_item_data)
			limbs_organs_by_tile[tile_key] = tile_saved_count + 1

			if(length(trash_to_save) >= MAX_PERSISTENT_TRASH)
				break

		// Break out of turf loop if cap reached
		if(length(trash_to_save) >= MAX_PERSISTENT_TRASH)
			break

	// If no trash to save, don't create file
	if(!length(trash_to_save))
		return

	// Prepare JSON structure
	var/list/json_data = list(
		"version" = 1,
		"map_name" = SSmapping.current_map?.map_name || "unknown",
		"trash" = trash_to_save
	)

	// Write to file
	var/map_name = SSmapping.current_map?.map_name || "unknown"
	var/sanitized_map_name = replacetext(map_name, " ", "_")
	var/json_file = file("[TRASH_DIRECTORY]/[sanitized_map_name].json")
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json_data))

/// Loads trash items from JSON file and spawns them on the map
/datum/controller/subsystem/persistence/proc/load_trash()
	var/map_name = SSmapping.current_map?.map_name
	if(!map_name)
		return

	var/sanitized_map_name = replacetext(map_name, " ", "_")
	var/json_file = file("[TRASH_DIRECTORY]/[sanitized_map_name].json")
	if(!fexists(json_file))
		return // First round on this map, no data to load

	var/list/json_data = json_decode(file2text(json_file))
	if(!json_data || !islist(json_data))
		return

	var/list/trash_list = json_data["trash"]
	if(!trash_list || !islist(trash_list))
		return

	// Pre-build cache of valid areas (avoids repeated get_area + istype checks)
	var/list/valid_areas = list()
	for(var/area/area_loc as anything in GLOB.areas)
		if(istype(area_loc, /area/station) && !istype(area_loc, /area/station/maintenance))
			valid_areas[area_loc] = TRUE

	var/loaded_count = 0
	var/list/trash_per_tile = list() // Track spawned trash per tile
	var/list/limbs_organs_per_tile = list() // Track spawned limbs/organs per tile

	for(var/list/trash_data in trash_list)
		// Early cap check to avoid unnecessary processing
		if(loaded_count >= MAX_PERSISTENT_TRASH)
			break

		// Validate data structure and type
		if(!islist(trash_data))
			continue

		var/item_type = text2path(trash_data["type"])
		if(!(ispath(item_type, /obj/item/trash) || ispath(item_type, /obj/item/bodypart) || ispath(item_type, /obj/item/organ)))
			continue

		// Validate and extract coordinates
		var/x = trash_data["x"]
		var/y = trash_data["y"]
		var/z = trash_data["z"]

		if(!isnum(x) || !isnum(y) || !isnum(z))
			continue

		// Verify station z-level early (before locate)
		if(!is_station_level(z))
			continue

		// Get the turf
		var/turf/target_turf = locate(x, y, z)
		if(!target_turf)
			continue

		// Check if area is valid using cached list
		var/area/area_loc = target_turf.loc
		if(!valid_areas[area_loc])
			continue

		// Check per-tile cap
		var/tile_key = "[x],[y],[z]"
		if(ispath(item_type, /obj/item/trash))
			var/tile_trash_count = trash_per_tile[tile_key] || 0
			if(tile_trash_count >= MAX_TRASH_PER_TILE)
				continue
		else
			var/tile_lo_count = limbs_organs_per_tile[tile_key] || 0
			if(tile_lo_count >= MAX_LIMBS_ORGANS_PER_TILE)
				continue

		// Spawn the item (trash/limb/organ)
		var/obj/item/new_item = new item_type(target_turf)
		if(!new_item)
			continue

		if(ispath(item_type, /obj/item/trash))
			var/tile_trash_count = trash_per_tile[tile_key] || 0
			trash_per_tile[tile_key] = tile_trash_count + 1
		else
			var/tile_lo_count = limbs_organs_per_tile[tile_key] || 0
			limbs_organs_per_tile[tile_key] = tile_lo_count + 1

		// Apply saved visual properties
		if(trash_data["icon_state"])
			new_item.icon_state = trash_data["icon_state"]
		if(trash_data["dir"])
			new_item.dir = trash_data["dir"]
		if(trash_data["name"])
			new_item.name = trash_data["name"]

		// Restore pixel offsets
		if(!isnull(trash_data["pixel_x"]))
			new_item.pixel_x = trash_data["pixel_x"]
		if(!isnull(trash_data["pixel_y"]))
			new_item.pixel_y = trash_data["pixel_y"]

		// Restore rounds persisted for janitor examine
			if(!isnull(trash_data["rounds_persisted"]))
				if(istype(new_item, /obj/item/trash))
					var/obj/item/trash/trash_item = new_item
					trash_item.rounds_persisted = trash_data["rounds_persisted"]
			else if(istype(new_item, /obj/item/bodypart))
				var/obj/item/bodypart/limb = new_item
				limb.rounds_persisted = trash_data["rounds_persisted"]
			else if(istype(new_item, /obj/item/organ))
				var/obj/item/organ/organ = new_item
				organ.rounds_persisted = trash_data["rounds_persisted"]

		// If this is a limb or organ, make it decayed/unusable for medical purposes
		if(istype(new_item, /obj/item/bodypart))
			var/obj/item/bodypart/limb = new_item
			limb.brute_dam = limb.max_damage
			limb.burn_dam = limb.max_damage
			limb.update_disabled()
			// Only add "decayed" prefix if it's not already there
			if(findtext(lowertext(limb.name), "decayed") != 1)
				limb.name = "decayed [limb.name]"
			limb.add_atom_colour(COLOR_SERVICE_LIME, FIXED_COLOUR_PRIORITY) // Green hue
		else if(istype(new_item, /obj/item/organ))
			var/obj/item/organ/organ = new_item
			organ.set_organ_damage(organ.maxHealth)
			organ.organ_flags |= ORGAN_FAILING
			organ.useable = FALSE
			// Only add "decayed" prefix if it's not already there
			if(findtext(lowertext(organ.name), "decayed") != 1)
				organ.name = "decayed [organ.name]"
			organ.add_atom_colour(COLOR_SERVICE_LIME, FIXED_COLOUR_PRIORITY) // Green hue
		loaded_count++

	if(loaded_count > 0)
		log_game("Loaded [loaded_count] persistent trash items for map '[map_name]'")

#undef PERSISTENCE_BASE_DIRECTORY
#undef CLEANABLES_DIRECTORY
#undef TRASH_DIRECTORY
#undef MAX_PERSISTENT_CLEANABLES
#undef MAX_CLEANABLES_PER_TILE
#undef MAX_PERSISTENT_TRASH
#undef MAX_TRASH_PER_TILE
#undef MAX_LIMBS_ORGANS_PER_TILE
