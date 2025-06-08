//VENUS EDIT REMOVAL BEGIN - Colorable Stipper Outfit - (Made redundant with the improved colourable stripper outfit)
/*
/obj/item/clothing/under/stripper_outfit
	name = "stripper outfit"
	desc = "An item of clothing that leaves little to the imagination."
	icon = 'modular_skyrat/modules/modular_items/lewd_items/icons/obj/lewd_clothing/lewd_uniform.dmi'
	worn_icon = 'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_uniform/lewd_uniform.dmi'
	worn_icon_digi = 'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_uniform/lewd_uniform-digi.dmi'
	worn_icon_taur_snake = 'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_uniform/lewd_uniform-snake.dmi'
	worn_icon_taur_paw = 'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_uniform/lewd_uniform-paw.dmi'
	worn_icon_taur_hoof = 'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_clothing/lewd_uniform/lewd_uniform-hoof.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	can_adjust = FALSE
	icon_state = "stripper_cyan"
	inhand_icon_state = "b_suit"
	interaction_flags_click = NEED_DEXTERITY
	unique_reskin = list("Cyan" = "stripper_cyan",
						"Yellow" = "stripper_yellow",
						"Green" = "stripper_green",
						"Red" = "stripper_red",
						"Latex" = "stripper_latex",
						"Orange" = "stripper_orange",
						"White" = "stripper_white",
						"Purple" = "stripper_purple",
						"Black" = "stripper_black",
						"Black-teal" = "stripper_tealblack")
*/
//VENUS EDIT REMOVAL END

/obj/item/clothing/under/stripper_outfit
	desc = "An item of clothing that leaves little to the imagination."
	name = "stripper outfit"
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	icon_state = "/obj/item/clothing/under/stripper_outfit"
	worn_icon = 'modular_zubbers/icons/mob/clothing/under/stripper.dmi'
	worn_icon_digi = 'modular_zubbers/icons/mob/clothing/under/stripper.dmi'
	greyscale_config = /datum/greyscale_config/stripper
	greyscale_config_worn = /datum/greyscale_config/stripper/worn
	flags_1 = IS_PLAYER_COLORABLE_1
	post_init_icon_state = "stripper"
	body_parts_covered = CHEST|GROIN|LEGS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	greyscale_colors = "#80b1ff"

	can_adjust = FALSE
