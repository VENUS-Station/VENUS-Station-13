//IRIS PORT START
/datum/techweb_node/parts_quantum
	id = TECHWEB_NODE_PARTS_QUANTUM
	display_name = "Quantum Technology"
	description = "Quantum stock parts are to Bluespace Technology what a spear is to a rock, something that has been properly and efficiently utilized."
	prereq_ids = list(TECHWEB_NODE_PARTS_BLUESPACE)
	design_ids = list(
		"quantum_scanning_module",
		"quantum_servo",
		"quantum_matter_bin",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_QUANTUM_POINTS)
	required_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier4_any)
	discount_experiments = list(
		/datum/experiment/scanning/points/slime/expert = TECHWEB_TIER_QUANTUM_POINTS/3,
		/datum/experiment/scanning/random/cytology/medium = TECHWEB_TIER_QUANTUM_POINTS/3,
		/datum/experiment/scanning/points/anomalies = TECHWEB_TIER_QUANTUM_POINTS/3
	)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/parts_power_quantum
	id = TECHWEB_NODE_PARTS_POWER_QUANTUM
	display_name = "Quantum Power Technology"
	description = "Full utilization of power storage and dispersal using Quantum Technology."
	prereq_ids = list(TECHWEB_NODE_PARTS_BLUESPACE)
	design_ids = list(
		"quantum_capacitor",
		"quantum_cell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_QUANTUM_POINTS)
	required_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier4_any)
	discount_experiments = list(
		/datum/experiment/scanning/points/slime/expert = TECHWEB_TIER_QUANTUM_POINTS/3,
		/datum/experiment/scanning/random/cytology/medium = TECHWEB_TIER_QUANTUM_POINTS/3,
		/datum/experiment/scanning/points/anomalies = TECHWEB_TIER_QUANTUM_POINTS/3
	)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/parts_laser_quantum
	id = TECHWEB_NODE_PARTS_LASER_QUANTUM
	display_name = "Integrated Quantum Laser Theory"
	description = "Theoretics made manifest in the venture of utilizing planck-length Quantum Scanners in order to make incredibly precise and controlled precisions."
	prereq_ids = list(TECHWEB_NODE_PARTS_BLUESPACE)
	design_ids = list(
		"quantum_micro_laser",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_QUANTUM_POINTS)
	required_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier4_any)
	discount_experiments = list(
		/datum/experiment/scanning/points/slime/expert = TECHWEB_TIER_QUANTUM_POINTS/3,
		/datum/experiment/scanning/random/cytology/medium = TECHWEB_TIER_QUANTUM_POINTS/3,
		/datum/experiment/scanning/points/anomalies = TECHWEB_TIER_QUANTUM_POINTS/3
	)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE)
//IRIS PORT END
