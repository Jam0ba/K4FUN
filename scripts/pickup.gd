class_name Pickup
extends Area3D

enum PICKUP_TYPES {HEALTH, WEAPON, AMMO}
enum WEAPONS {GLOCK, M4, SHOTGUN}
@export var pickup_type = PICKUP_TYPES.HEALTH
@export var weapon_type = WEAPONS.GLOCK
@export var pickup_amnt = 20

func Pickuped():
	queue_free()
