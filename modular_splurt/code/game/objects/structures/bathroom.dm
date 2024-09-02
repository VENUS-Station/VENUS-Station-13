/obj/structure/curtain
	icon_state = "curtain_open"

/obj/structure/curtain/goliath
	name = "goliath curtain"
	desc = "Because tribals need privacy too."
	icon = 'modular_splurt/icons/obj/structures/bathroom.dmi'
	icon_state = "goliath_curtain_open"
	color = null //Default color, didn't bother hardcoding other colors, mappers can and should easily change it.
	alpha = 200 //Mappers can also just set this to 255 if they want curtains that can't be seen through <- No longer necessary unless you don't want to see through it no matter what.
	layer = SIGN_LAYER
	anchored = TRUE
	max_integrity = 125.

/obj/structure/curtain/update_icon_state()
	. = ..()
	if(!open)
		icon_state = replacetext(initial(icon_state), "open", "closed")
	else
		icon_state = initial(icon_state)
