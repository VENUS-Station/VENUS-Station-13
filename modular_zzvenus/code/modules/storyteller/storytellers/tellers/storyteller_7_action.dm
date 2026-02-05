/datum/storyteller/action
	name = "Action Andy (Medium-High Chaos)"
	desc = "Action Andy tries to recreate the classic random event system, generating events 25% more frequently than Balanced Barry (but only for standard events, not antagonists). \
	He maintains the same unbiased event selection as Balanced Barry, just running them more frequently. \
	Perfect for players who miss the old days but still want a balanced experience."
	welcome_text = "...and the only thing that comes out, that's left of you, is your eyeball, you'r- you're PROBABLY DEAD!"
	track_data = /datum/storyteller_data/tracks/action
	antag_divisor = 8
	storyteller_type = STORYTELLER_TYPE_ALWAYS_AVAILABLE

/datum/storyteller_data/tracks/action
	threshold_mundane = 900    // 75% of Default Andy's 1200 (25% faster)
	threshold_moderate = 1350   // 75% of Default Andy's 1800 (25% faster)
	threshold_major = 5000     // 62.5% of Default Andy's 8000 (37.5% faster)
