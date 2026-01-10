/client/ooc(msg as text)
	var/vibe_check = SSdiscord?.check_login(usr)
	if(isnull(vibe_check))
		to_chat(usr, span_notice("The server is still starting up. Please wait... "))
		return
	else if(!vibe_check) //Dirty but I guess we gotta tell when the subsystem hasn't started
		to_chat(usr, span_warning("You must link your discord account to your ckey in order to join the game. Join our <a style=\"color: #ff00ff;\" href=\"[CONFIG_GET(string/discord_link)]\">discord</a> and open a Verification Request Ticket. It won't take you more than two minutes :)<br>Remember that to maintain in-game verification you MUST remain in the discord.<br>Ahelp or ask staff in the discord if this is an error."))
		return
	var/vetted_check = SSplayer_ranks?.check_vetted(usr)
	if(isnull(vetted_check))
		to_chat(usr, span_notice("The server is still starting up. Please wait... "))
		return
	else if(!vetted_check)
		to_chat(usr, span_warning("You must be vetted in order to use OOC. Please get vetted through the appropriate channels.<br>Ahelp or ask staff in the discord if this is an error."))
		return

	. = ..()
