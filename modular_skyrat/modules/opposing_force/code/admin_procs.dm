//VENUS ADDITION START
#define OPFOR_STATUS_MESSAGE_OPEN "Antagonists have been requested for this shift. Apply via in-game OPFOR if interested."
#define OPFOR_STATUS_MESSAGE_CLOSED "OPFOR requests are now closed, await the next chance if interested!"
#define OPFOR_LOBBY_NOTICE_OPEN "<span class='adminhelp'>ANTAG-ENABLED SHIFT - Apply via OPFOR to be an Antagonist.</span><br><br><span>Join as your character → press ESC to open the menu → click OPFOR button</span>"
#define OPFOR_LOBBY_NOTICE_CLOSED null

/proc/send_opfor_status_message(message, include_ping = TRUE)
	if(!message)
		return
	var/list/channel_tags = CONFIG_GET(str_list/channel_announce_new_game)
	if(!length(channel_tags))
		return
	var/role_id = CONFIG_GET(string/opfor_alert_role_id)
	var/prefix = (include_ping && length(role_id)) ? "<@&[role_id]> " : ""
	var/datum/tgs_message_content/tgs_message = new("[prefix][message]")
	for(var/channel_tag in channel_tags)
		send2chat(tgs_message, channel_tag)
//VENUS ADDITION END

ADMIN_VERB(request_more_opfor, R_FUN, "Request OPFOR", "Request players sign up for opfor if they have antag on.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "Please confirm you want to ask all antagonist enabled players to submit an OPFOR?", "Confirm Request OPFOR", list("Yes", "No"))
	if(confirm != "Yes")
		return
//VENUS ADDITION START - OPFOR request options
	var/list/notice_options = list("Send lobby notice", "Send status message")
	var/list/selected_options = tgui_input_checkboxes(user, "Select any optional broadcasts to send with the OPFOR request.", "Request OPFOR Options", notice_options, 0, notice_options.len)
	if(isnull(selected_options))
		return
	var/list/selected_labels = list()
	if(islist(selected_options))
		for(var/entry in selected_options)
			if(islist(entry))
				selected_labels += entry[1]
			else
				selected_labels += entry
	else
		selected_labels += selected_options

	var/send_lobby_notice = ("Send lobby notice" in selected_labels)
	var/send_status_message = ("Send status message" in selected_labels)

	if(send_lobby_notice)
		SStitle.set_notice(OPFOR_LOBBY_NOTICE_OPEN)

	if(send_status_message)
		send_opfor_status_message(OPFOR_STATUS_MESSAGE_OPEN)
//VENUS ADDITION END
	var/asked = 0
	for(var/mob/living/carbon/human/human in GLOB.alive_player_list)
		if(human.client?.prefs?.read_preference(/datum/preference/toggle/be_antag))
			to_chat(human, custom_boxed_message("green_box", span_greentext("The admins are looking for OPFOR players, if you're interested, sign up in the OOC tab!")))
			asked++
	message_admins("[ADMIN_LOOKUP(user)] has requested more OPFOR players! (Asked: [asked] players)")

//VENUS ADDITION START - Unrequest OPFOR
ADMIN_VERB(unrequest_opfor, R_FUN, "Unrequest OPFOR", "Stops requesting OPFOR and updates status/lobby notices.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "Please confirm you want to close OPFOR requests.", "Confirm Unrequest OPFOR", list("Yes", "No"))
	if(confirm != "Yes")
		return

	SStitle.set_notice(OPFOR_LOBBY_NOTICE_CLOSED)
	send_opfor_status_message(OPFOR_STATUS_MESSAGE_CLOSED, FALSE)
	message_admins("[ADMIN_LOOKUP(user)] has closed OPFOR requests.")
//VENUS ADDITION END

ADMIN_VERB(view_opfors, R_ADMIN, "View OPFORs", "View OPFORs.", ADMIN_CATEGORY_GAME)
	user.mob.client?.view_opfors()

/client/proc/view_opfors()
	if(holder)
		var/list/dat = list("<html>")
		dat += SSopposing_force.get_check_antag_listing()
		dat += "</html>"
		usr << browse(dat.Join(), "window=roundstatus;size=500x500")
		log_admin("[key_name(usr)] viewed OPFORs.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "View OPFORs")

//VENUS ADDITION START
#undef OPFOR_STATUS_MESSAGE_OPEN
#undef OPFOR_STATUS_MESSAGE_CLOSED
#undef OPFOR_LOBBY_NOTICE_OPEN
#undef OPFOR_LOBBY_NOTICE_CLOSED
//VENUS ADDITION END
