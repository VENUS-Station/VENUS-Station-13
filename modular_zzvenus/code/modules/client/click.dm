/**
 * Venus module - Perception-based look further functionality
 * Allows players to look further away with ctrl+right click
 */

/**
 * Ctrl+Right Click
 * Allows players to look further away, with distance based on perception
 */
/mob/proc/CtrlRightClickOn(atom/A)
	return FALSE

/mob/living/CtrlRightClickOn(atom/A)
	if(isturf(A))
		look_further(A)
		return TRUE
	return FALSE

/mob/living/proc/look_further(turf/T)
	if(!client)
		return
	if(client.perspective != MOB_PERSPECTIVE)
		stop_looking()
		return
	if(client.pixel_x || client.pixel_y)
		stop_looking()
		return
	if(!can_look_up())
		return
	if(!istype(T))
		return
	changeNext_move(CLICK_CD_MELEE)

	var/_x = T.x-loc.x
	var/_y = T.y-loc.y
	var/dist = get_dist(src, T)
	var/message = span_info("[src] looks into the distance.")
	if(dist > 10 || dist <= 2)
		return
	face_atom(T) //Make sure we turn around
	//hide_cone()
	var/ttime = 11
	if(STAPER > 5)
		ttime = 10 - (STAPER - 5)
		if(ttime < 0)
			ttime = 1
	if(STAPER <= 10)
		var/offset = (10 - STAPER) * 2
		if(STAPER == 10)
			offset = 1
		else
			message = span_info("[src] struggles to look ahead.")
		if(_x > 0)
			_x -= offset
			_x = max(0, _x)
		else if(_x != 0)
			_x += offset
			_x = min(0, _x)
		if(_y > 0)
			_y -= offset
			_y = max(0,_y)
		else if(_y != 0)
			_y += offset
			_y = min(0,_y)
	else if(STAPER > 11)
		var/offset = STAPER - 10
		if(offset > 5)	//Caps the bonus at 15 PER, which is a whole extra screen in an orthogonal direction. Anymore will get disorienting.
			offset = 5
		if(STAPER >= 12)
			message = span_info("[src] easily peers afar.")
		if(_x > 0)
			_x += offset
		else if(_x != 0)
			_x -= offset
		if(_y > 0)
			_y += offset
		else if(_y != 0)
			_y -= offset
	// if(m_intent != MOVE_INTENT_SNEAK)
	if(_y == 0 && _x == 0)	//Their PER was too low to see anything.
		message = span_info("[src] oafishly stares in front of themselves.")
	visible_message(message)
	animate(client, pixel_x = world.icon_size*_x, pixel_y = world.icon_size*_y, ttime)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(stop_looking))
	RegisterSignal(src, COMSIG_ATOM_PRE_DIR_CHANGE, PROC_REF(stop_looking))
	// update_cone_show()

/mob/living/proc/stop_looking()
	if(!client)
		return
	animate(client, pixel_x = 0, pixel_y = 0, 2, easing = SINE_EASING)
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0
	reset_perspective()
	// update_cone_show()

