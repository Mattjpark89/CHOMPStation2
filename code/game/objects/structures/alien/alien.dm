/obj/structure/alien //Gurg Addition, framework for alien structures.
	name = "alien thing"
	desc = "There's something alien about this."
	icon = 'icons/mob/alien.dmi'
	layer = ABOVE_JUNK_LAYER
	var/health = 50
	unacidable = TRUE
	anchored = TRUE

/obj/structure/alien/proc/healthcheck()
	if(health <=0)
		set_density(0)
		qdel(src)
	return

/obj/structure/alien/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/structure/alien/ex_act(severity)
	switch(severity)
		if(1.0)
			health-=50
		if(2.0)
			health-=50
		if(3.0)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/structure/alien/hitby(AM as mob|obj)
	..()
	visible_message(span_danger("\The [src] was hit by \the [AM]."))
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/structure/alien/attack_generic(var/mob/user, var/damage, var/attack_verb)
	visible_message(span_danger("[user] [attack_verb] the [src]!"))
	playsound(src, 'sound/effects/attackblob.ogg', 100, 1)
	user.do_attack_animation(src)
	health -= damage
	healthcheck()
	return

/obj/structure/alien/attackby(obj/item/W as obj, mob/user as mob)

	user.setClickCooldown(user.get_attack_speed(W))
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(src, 'sound/effects/attackblob.ogg', 100, 1)
	visible_message(span_danger("[user] attacks the [src]!"))
	healthcheck()
	..()
	return

/obj/structure/alien/attack_hand(mob/user as mob)
	usr.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if (HULK in usr.mutations)
		visible_message(span_warning("[usr] destroys the [name]!"))
		health = 0
	else

		// Aliens can get straight through these.
		if(istype(usr,/mob/living/carbon))
			if(user.a_intent == I_HURT) // CHOMPAdd
				var/mob/living/carbon/M = usr
				if(locate(/obj/item/organ/internal/xenos/hivenode) in M.internal_organs)
					visible_message (span_warning("[usr] strokes the [name] and it melts away!"), 1)
					health = 0
					healthcheck()
					return
				if(locate(/obj/item/organ/internal/xenos/resinspinner/replicant) in M.internal_organs)
					if(!do_after(M, 3 SECONDS))
						return
					visible_message (span_warning("[usr] strokes the [name] and it melts away!"), 1)
					health = 0
					healthcheck()
					return
			visible_message(span_warning("[usr] claws at the [name]!"))
			health -= rand(5,10)
	healthcheck()
	return

/obj/structure/alien/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density
