/**
 * Memory for knowing what wires do.
 * Stores a list of known wires for different devices.
 */
/datum/memory/wire_knowledge
	name = "Wire Knowledge"
	story_value = STORY_VALUE_NONE // Technical knowledge, not really a story.
	memory_flags = MEMORY_FLAG_NOMOOD | MEMORY_FLAG_NOLOCATION | MEMORY_NO_STORY | MEMORY_FLAG_NOPERSISTENCE

	/// Assoc list: "[dictionary_key]" -> list(color = wire_id)
	var/list/known_wires = list()
	/// Assoc list: "[dictionary_key]" -> "Proper Name" (e.g. "Command Airlock")
	var/list/wire_names = list()

/datum/memory/wire_knowledge/proc/learn_wire(key, color, wire_id, proper_name)
	var/key_str = "[key]"
	if(!known_wires[key_str])
		known_wires[key_str] = list()

	known_wires[key_str][color] = wire_id
	if(proper_name)
		wire_names[key_str] = proper_name

/datum/memory/wire_knowledge/proc/knows_wire(key, color, wire_id)
	var/key_str = "[key]"
	if(!known_wires[key_str])
		return FALSE

	// If we just check by color, we assume the wire_id matches what is there.
	// Since we learn (color -> id), if the user queries "What is Red on Key?", we return the ID.
	// This proc checks if we know it.
	return (known_wires[key_str][color] == wire_id)

/datum/memory/wire_knowledge/get_names()
	return list("Knowledge of Wires")

/datum/memory/wire_knowledge/get_memory_text()
	var/list/lines = list("I have learned the following wire connections:")

	for(var/key_str in known_wires)
		var/list/wires = known_wires[key_str]
		if(!length(wires))
			continue

		// Try to use the stored proper name, or fall back to the key string.
		var/readable_key = wire_names[key_str] || key_str

		var/line = "For [readable_key]:"
		var/list/wire_descs = list()
		for(var/color in wires)
			var/wire_id = wires[color]
			wire_descs += "[color] is [wire_id]"

		line += " [english_list(wire_descs)]."
		lines += line

	return jointext(lines, "\n\n")
