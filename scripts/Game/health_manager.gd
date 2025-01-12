class_name HealthManager
extends Node3D

@onready var blood_raycast = $BloodRaycast
@export var blood_VFX : PackedScene
@export var blood_decal : PackedScene
@export var gibbed_model : PackedScene


@export var blood_splatter_count : float = 3.0
@export var blood_splatter_range : float = 2.0
@export var blood_slpatter_size_variance : float = 0.5
@export var max_health : int = 100
@onready var cur_health : int = max_health
@export var gib_when_damage_taken : int = 5
@export var gib_spawn_amount : int = 8

@export var verbos : bool = false
var hast_gibbed : bool = false



signal died
signal healed
signal damaged
signal gibbed
signal health_changed(cur_health, max_health)

func _ready() -> void:
	health_changed.emit(cur_health, max_health)
	if verbos:
		print("starting health: %s/%s" % [cur_health, max_health])
		


var damage_taken_this_frame : int = 0
var last_frame_damage : int = -1
func hurt(damage_data : DamageData) -> void:
	spawn_blood_effect(damage_data)
	
	var cur_frame = Engine.get_process_frames()
	if last_frame_damage != cur_frame:
		damage_taken_this_frame = 0
	last_frame_damage = cur_frame
	damage_taken_this_frame += damage_data.amount
	
	var dead = cur_health <= 0
	if dead and damage_taken_this_frame >= gib_when_damage_taken:
		gib()
	
	if dead:
		return
	
	if cur_health <= 0:
		return
	
	cur_health -= damage_data.amount
	dead = cur_health <= 0
	
	if dead:
		died.emit()
		if dead and damage_taken_this_frame >= gib_when_damage_taken:
			gib()
	else:
		damaged.emit()
	health_changed.emit(cur_health, max_health)
	if verbos:
		print("damage for %s, health: %s/%s" % [damage_data.amount, cur_health, max_health])

func gib() -> void:
	if hast_gibbed:
		return
	hast_gibbed = true
	gibbed.emit()
	
	for _i in gib_spawn_amount:
		var gib_inst = gibbed_model.instantiate()
		get_tree().root.add_child(gib_inst)
		gib_inst.global_position = global_position

func heal(amount : int) -> void:
	if cur_health <= 0:
		return
	cur_health = clamp(cur_health + amount, 0 , max_health)
	healed.emit()
	health_changed.emit(cur_health,max_health)
	if verbos:
		print("damage for %s, health: %s/%s" % [amount, cur_health, max_health])

func spawn_blood_effect(damage_data: DamageData):
	var blood_hit_eff = blood_VFX.instantiate()
	get_tree().root.add_child(blood_hit_eff)
	blood_hit_eff.global_position = damage_data.hit_pos
	
	blood_raycast.enabled = true
	for _i in blood_splatter_count:
		var h_angle = randf_range(0.0, PI / 2.0)
		var v_angle = randf_range(0.0, TAU)
		var dir =  Vector3.DOWN.rotated(Vector3.RIGHT, h_angle)
		dir = dir.rotated(Vector3.UP, v_angle)
		var raycast_to = global_position + dir * blood_splatter_range
		blood_raycast.target_position = blood_raycast.to_local(raycast_to)
		blood_raycast.force_raycast_update()
		if !blood_raycast.is_colliding():
			continue
		
		var hit_pos = blood_raycast.get_collision_point()
		var hit_norm = blood_raycast.get_collision_normal()
		var blood_decals = blood_decal.instantiate()
		get_tree().root.add_child(blood_decals)
		blood_decals.global_position = hit_pos
		var look_at_pos = hit_pos + hit_norm
		if hit_norm.is_equal_approx(Vector3.UP) or hit_norm.is_equal_approx(Vector3.DOWN):
			blood_decals.look_at(look_at_pos, Vector3.RIGHT)
		else:
			blood_decals.look_at(look_at_pos)
		
		blood_decals.rotate_object_local(Vector3.FORWARD, randf_range(0.0, TAU))
		blood_decals.scale *= 1.0 + randf_range(-blood_slpatter_size_variance, blood_slpatter_size_variance)
	blood_raycast.enabled = false
