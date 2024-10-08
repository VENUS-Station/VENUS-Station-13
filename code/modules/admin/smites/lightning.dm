/// Strikes the target with a lightning bolt
/*/datum/smite/lightning
	name = "Lightning bolt"

/datum/smite/lightning/effect(client/user, mob/living/carbon/human/target as mob)
	. = ..()
	if(prob(75))
		playsound(target, 'modular_splurt/sound/misc/NOW.ogg', 75, FALSE)
		sleep(4 SECONDS)
	var/turf/T = get_step(get_step(user, NORTH), NORTH)
	T.Beam(target, icon_state="lightning[rand(1,12)]", time = 5)
	target.adjustFireLoss(75)
	target.electrocution_animation(40)
	to_chat(target, "<span class='userdanger'>The gods have punished you for your sins!</span>")
*/

//BROKEN!!! FIX LATER!!
