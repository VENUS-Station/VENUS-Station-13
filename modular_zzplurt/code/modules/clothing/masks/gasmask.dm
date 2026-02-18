// If you have a dart in your mask, an overlay is shown on it
/obj/item/clothing/mask/gas

/obj/item/clothing/mask/gas/update_overlays()
	. = ..()
	if(cig)
		var/mutable_appearance/dart_appearance = new /mutable_appearance(cig)
		dart_appearance.plane = FLOAT_PLANE
		dart_appearance.layer = FLOAT_LAYER
		dart_appearance.pixel_x = -ICON_SIZE_X/8
		dart_appearance.pixel_y = -ICON_SIZE_Y/8
		dart_appearance.transform *= 0.5
		. += dart_appearance

/obj/item/clothing/mask/gas/cosmetic
	name = "aesthetic gas mask"
	desc = "A face-covering mask that resembles a traditional gas mask, but without the breathing functionality."
	clothing_flags = NONE
	armor_type = /datum/armor/none

// GWTB-inspired thing wooo
/obj/item/clothing/mask/gas/goner
	name = "operative trencher gas mask"
	desc = "A protective, head-covering mask. This gas mask model is made by mooks and romantically apocalyptic people. It even have proper filter on!"
	icon = 'modular_zzplurt/icons/obj/clothing/masks.dmi'
	worn_icon = 'modular_zzplurt/icons/mob/clothing/mask.dmi'
	worn_icon_muzzled = 'modular_zzplurt/icons/mob/clothing/mask_muzzle.dmi'
	icon_state = "goner_mask"
	flags_inv = HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR | HIDESNOUT
	armor_type = /datum/armor/none

/obj/item/clothing/mask/gas/goner/fake
	name = "trencher gas mask"
	desc = "A head-covering mask. This gas mask model is made by mooks and romantically apocalyptic people. Still isn't good for blocking gas flow."
	armor_type = /datum/armor/none
