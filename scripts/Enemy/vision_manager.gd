class_name  VisionManager
extends Node3D

@export var sight_arc : float = 100.0
@export var max_sight_range : float = 15.0
@export var always_detect_in_range : float = 2.0
@onready var los = $LOSRayCast3D

func can_see_target(target : Node3D):
	var target_pos = target.global_position + Vector3.UP * 1.5
	var dir_to_target = global_position.direction_to(target_pos)
	var dist_to_target = global_position.distance_to(target_pos)
	var fwd = -global_transform.basis.z
	
	if dist_to_target > max_sight_range:
		return false
	
	if dist_to_target < always_detect_in_range:
		return true
		
	
	if fwd.angle_to(dir_to_target) > deg_to_rad(sight_arc / 2.0):
		return false
		
	
	los.enabled = true
	los.target_position = los.to_local(target_pos)
	los.force_raycast_update()
	var has_los = !los.is_colliding()
	los.enabled = false
	
	return has_los

func is_facing_target(target : Node3D):
	var pos = to_local(target.global_position)
	return pos.z < 0.0 and abs(pos.x) < 0.5
