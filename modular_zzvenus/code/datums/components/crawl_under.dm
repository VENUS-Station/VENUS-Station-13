/// Allows a living mob to crawl under the parent by drag-dropping itself while lying down.
/datum/component/crawl_under
	/// Time it takes to crawl under the object.
	var/crawl_time = 3 SECONDS
	/// Living mobs currently in our turf, tracked for body-position updates.
	var/list/tracked_living_mobs = list()

/datum/component/crawl_under/Initialize(crawl_time = 3 SECONDS)
	. = ..()
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE
	src.crawl_time = crawl_time

/datum/component/crawl_under/RegisterWithParent()
	var/static/list/turf_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_turf_entered),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_turf_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_turf_exited),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, turf_connections)

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_tags))
	RegisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(on_mouse_drop))
	RegisterSignal(parent, COMSIG_ATOM_TRIED_PASS, PROC_REF(can_crawl_through))

	var/turf/current_turf = get_turf(parent)
	if(current_turf)
		for(var/mob/living/living_mob in current_turf)
			register_living_mob(living_mob)

/datum/component/crawl_under/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE_TAGS, COMSIG_MOUSEDROPPED_ONTO, COMSIG_ATOM_TRIED_PASS))
	for(var/mob/living/living_mob as anything in tracked_living_mobs.Copy())
		unregister_living_mob(living_mob)

/datum/component/crawl_under/proc/on_turf_entered(datum/source, atom/movable/entered, atom/old_loc)
	SIGNAL_HANDLER
	if(isliving(entered))
		register_living_mob(entered)

/datum/component/crawl_under/proc/on_turf_exited(datum/source, atom/movable/exited, direction)
	SIGNAL_HANDLER
	if(isliving(exited))
		unregister_living_mob(exited)

/datum/component/crawl_under/proc/register_living_mob(mob/living/living_mob)
	if(tracked_living_mobs[living_mob])
		return
	tracked_living_mobs[living_mob] = TRUE
	RegisterSignals(living_mob, list(COMSIG_LIVING_SET_BODY_POSITION, COMSIG_QDELETING), PROC_REF(on_living_state_changed))
	living_mob.update_under_table_layer()

/datum/component/crawl_under/proc/unregister_living_mob(mob/living/living_mob)
	if(!tracked_living_mobs[living_mob])
		return
	tracked_living_mobs.Remove(living_mob)
	UnregisterSignal(living_mob, list(COMSIG_LIVING_SET_BODY_POSITION, COMSIG_QDELETING))
	if(!QDELETED(living_mob))
		// Only remove the trait if the mob isn't moving to another crawlable turf.
		if(HAS_TRAIT(living_mob, TRAIT_UNDER_CRAWLING) && !turf_has_other_crawl_under(get_turf(living_mob)))
			REMOVE_TRAIT(living_mob, TRAIT_UNDER_CRAWLING, TRAIT_UNDER_CRAWLING)
			REMOVE_TRAIT(living_mob, TRAIT_IGNORE_ELEVATION, TRAIT_UNDER_CRAWLING)
		living_mob.update_under_table_layer()

/// Returns TRUE if the given turf contains any crawl_under component other than this one.
/datum/component/crawl_under/proc/turf_has_other_crawl_under(turf/check_turf)
	if(!check_turf)
		return FALSE
	for(var/atom/thing in check_turf)
		var/datum/component/crawl_under/other = thing.GetComponent(/datum/component/crawl_under)
		if(other && other != src)
			return TRUE
	return FALSE

/datum/component/crawl_under/proc/on_living_state_changed(mob/living/source)
	SIGNAL_HANDLER
	if(!isliving(source))
		return
	if(QDELETED(source))
		tracked_living_mobs.Remove(source)
		return
	// If the mob stands up, they're no longer crawling under.
	if(source.body_position == STANDING_UP && HAS_TRAIT(source, TRAIT_UNDER_CRAWLING))
		REMOVE_TRAIT(source, TRAIT_UNDER_CRAWLING, TRAIT_UNDER_CRAWLING)
		REMOVE_TRAIT(source, TRAIT_IGNORE_ELEVATION, TRAIT_UNDER_CRAWLING)
	source.update_under_table_layer()

/// Allows mobs that are actively under-crawling to pass through this object.
/datum/component/crawl_under/proc/can_crawl_through(datum/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(isliving(mover) && HAS_TRAIT(mover, TRAIT_UNDER_CRAWLING))
		return COMSIG_COMPONENT_PERMIT_PASSAGE

/datum/component/crawl_under/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list["crawlable under"] = "You can drag yourself onto it while lying down to crawl under it."

/datum/component/crawl_under/proc/can_crawl_under(atom/source, mob/living/user)
	if(!source.IsReachableBy(user))
		return FALSE
	if(user.body_position != LYING_DOWN)
		return FALSE
	if(user.loc == source.loc)
		return FALSE
	var/dir_step = get_dir(user, source.loc)
	// Keep border handling consistent with climbable behavior.
	if(source.flags_1 & ON_BORDER_1 && user.loc != source.loc && (dir_step & source.dir) == source.dir)
		return FALSE
	return TRUE

/datum/component/crawl_under/proc/do_crawl_under(atom/source, mob/living/user, params)
	if(!can_crawl_under(source, user))
		return FALSE
	var/original_density = source.density
	source.set_density(FALSE)
	var/dir_step = get_dir(user, source.loc)
	var/same_loc = source.loc == user.loc
	if(source.flags_1 & ON_BORDER_1 && (same_loc || !(dir_step & REVERSE_DIR(source.dir))))
		if(ISDIAGONALDIR(source.dir) && same_loc)
			if(params)
				var/list/modifiers = params2list(params)
				var/x_dist = (text2num(LAZYACCESS(modifiers, ICON_X)) - ICON_SIZE_X / 2) * (source.dir & WEST ? -1 : 1)
				var/y_dist = (text2num(LAZYACCESS(modifiers, ICON_Y)) - ICON_SIZE_Y / 2) * (source.dir & SOUTH ? -1 : 1)
				dir_step = (x_dist >= y_dist ? (EAST|WEST) : (NORTH|SOUTH)) & source.dir
		else
			dir_step = get_dir(user, get_step(source, source.dir))
	ADD_TRAIT(user, TRAIT_UNDER_CRAWLING, TRAIT_UNDER_CRAWLING)
	ADD_TRAIT(user, TRAIT_IGNORE_ELEVATION, TRAIT_UNDER_CRAWLING)
	. = step(user, dir_step)
	source.set_density(original_density) //We don't set to true unlike TG does because we allow crawling under non-dense things
	if(.)
		user.update_under_table_layer()
	else
		REMOVE_TRAIT(user, TRAIT_UNDER_CRAWLING, TRAIT_UNDER_CRAWLING)
		REMOVE_TRAIT(user, TRAIT_IGNORE_ELEVATION, TRAIT_UNDER_CRAWLING)

/datum/component/crawl_under/proc/crawl_under(atom/source, mob/living/user, params)
	if(!can_crawl_under(source, user))
		return
	source.add_fingerprint(user)
	user.visible_message(
		span_warning("[user] starts crawling under [source]."),
		span_notice("You start crawling under [source]..."),
	)
	if(!do_after(user, crawl_time, source, extra_checks = CALLBACK(src, PROC_REF(can_crawl_under), source, user)))
		to_chat(user, span_warning("You fail to crawl under [source]."))
		return
	if(QDELETED(source) || !can_crawl_under(source, user))
		return
	if(!do_crawl_under(source, user, params))
		to_chat(user, span_warning("You fail to crawl under [source]."))
		return
	user.visible_message(
		span_warning("[user] crawls under [source]."),
		span_notice("You crawl under [source]."),
	)
	log_combat(user, source, "crawled under")

/datum/component/crawl_under/proc/on_mouse_drop(atom/source, atom/movable/dropped_atom, mob/user, params)
	SIGNAL_HANDLER
	if(user != dropped_atom || !isliving(dropped_atom))
		return
	if(!HAS_TRAIT(dropped_atom, TRAIT_FENCE_CLIMBER) && !HAS_TRAIT(dropped_atom, TRAIT_CAN_HOLD_ITEMS))
		return
	var/mob/living/living_target = dropped_atom
	if(!(living_target.mobility_flags & MOBILITY_MOVE))
		return
	if(!can_crawl_under(source, living_target))
		return
	INVOKE_ASYNC(src, PROC_REF(crawl_under), source, living_target, params)
	return COMPONENT_CANCEL_MOUSEDROPPED_ONTO

/// Updates mob layer while lying down so crawl-under surfaces render above the mob.
/mob/living/proc/update_under_table_layer()
	if(body_position == LYING_DOWN && HAS_TRAIT(src, TRAIT_UNDER_CRAWLING))
		layer = PROJECTILE_HIT_THRESHHOLD_LAYER
		return

	if(layer == PROJECTILE_HIT_THRESHHOLD_LAYER)
		layer = body_position == LYING_DOWN ? LYING_MOB_LAYER : initial(layer)
