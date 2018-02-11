/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'

	var/obj/item/weapon/stock_parts/cell/power_supply //What type of power cell this uses
	var/cell_type = /obj/item/weapon/stock_parts/cell/high
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/can_charge = 1 //Can it be charged in a recharger?
	ammo_x_offset = 2
	var/shaded_charge = 0 //if this gun uses a stateful charge bar for more detail
	var/replaceable_battery = 1
/obj/item/weapon/gun/energy/emp_act(severity)
	if(power_supply)
		power_supply.use(round(power_supply.charge / severity))
		update_icon()


/obj/item/weapon/gun/energy/New()
	..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)
	power_supply.give(power_supply.maxcharge)
	var/obj/item/ammo_casing/energy/shot
	for (var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	update_icon()
	return

/obj/item/weapon/gun/energy/examine(mob/user)
	..()
	if(replaceable_battery)
		if(power_supply)
			user << "It draws power from [power_supply]"
		else
			user << "It lacks power source"

/obj/item/weapon/gun/energy/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, params)
	newshot() //prepare a new shot
	..()

/obj/item/weapon/gun/energy/can_shoot(mob/user)
	if(power_supply)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		return power_supply.charge >= shot.e_cost
	else
		user << "<span class='notice'>[src] is missing battery!</span>"
		return

/obj/item/weapon/gun/energy/newshot()
	if (!ammo_type || !power_supply)
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(power_supply.charge >= shot.e_cost) //if there's enough power in the power_supply cell...
		chambered = shot //...prepare a new shot based on the current ammo type selected
		chambered.newshot()
	return

/obj/item/weapon/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		power_supply.use(shot.e_cost)//... drain the power_supply cell
	chambered = null //either way, released the prepared shot
	return

/obj/item/weapon/gun/energy/proc/select_fire(mob/living/user)
	select++
	if (select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name)
		user << "<span class='notice'>[src] is now set to [shot.select_name].</span>"
	update_icon()
	return

/obj/item/weapon/gun/energy/update_icon()
	var/ratio
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(power_supply)
		ratio = power_supply.charge / power_supply.maxcharge
		ratio = min(Ceiling(ratio*4) * 25, 100)
		if(power_supply.charge < shot.e_cost)
			ratio = 0 //so the icon changes to empty if the charge isn't zero but not enough for a shot.
	else
		ratio = 0

	switch(modifystate)
		if (0)
			icon_state = "[initial(icon_state)][ratio]"
		if (1)
			icon_state = "[initial(icon_state)][shot.select_name][ratio]"
		if (2)
			icon_state = "[initial(icon_state)][shot.select_name][ratio]"

	overlays.Cut()
	if(F)
		if(F.on)
			overlays += "flight-[initial(icon_state)]-on"
		else
			overlays += "flight-[initial(icon_state)]"
	return

/obj/item/weapon/gun/energy/ui_action_click()
	toggle_gunlight()

/obj/item/weapon/gun/energy/suicide_act(mob/user)
	if (src.can_shoot())
		user.visible_message("<span class='suicide'>[user] is putting the barrel of the [src.name] in \his mouth.  It looks like \he's trying to commit suicide.</span>")
		sleep(25)
		if(user.l_hand == src || user.r_hand == src)
			user.visible_message("<span class='suicide'>[user] melts \his face off with the [src.name]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			power_supply.use(shot.e_cost)
			update_icon()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow \his brains out with the [src.name]! It looks like \he's trying to commit suicide!</b></span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1, -1)
		return (OXYLOSS)

/obj/item/weapon/gun/energy/AltClick(mob/user)
	if(replaceable_battery)
		if(power_supply)
			power_supply.loc = src.loc
			user.put_in_hands(power_supply)
			power_supply.updateicon()
			power_supply = null
			user << "<span class='notice'>You eject the cell out of \the [src].</span>"
		else
			user << "<span class='notice'>There's no cell in \the [src].</span>"
		update_icon()

/obj/item/weapon/gun/energy/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/stock_parts/cell/) && replaceable_battery)
		if(!power_supply)
			var/obj/item/weapon/stock_parts/cell/battery = I
			user.remove_from_mob(battery)
			power_supply = battery
			power_supply.loc = src
			user << "<span class='notice'>You load a new cell into \the [src].</span>"
			battery.updateicon()
			update_icon()
			return 1
		else
			user << "<span class='notice'>There's already a battery in \the [src].</span>"
			return
	..()