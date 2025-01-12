class_name BulletEmitter
extends Node3D


var bodies_to_exclude = []
var damage : int = 1

func set_damage(d: int) -> void:
	damage = d
	for child in get_children():
		if child is BulletEmitter:
			child.set_damage(d)

func set_bodies_to_exclude(bodies : Array) -> void:
	bodies_to_exclude = bodies
	for child in get_children():
		if child is BulletEmitter:
			child.set_bodies_to_exclude(bodies)

func fire():
	for child in get_children():
		if child is BulletEmitter:
			child.fire()
