class_name EnemyMoverAI
extends Node3D

@export var jump_force : float = 15.0
@export var gravity : float = 30.0

@export var max_speed : float = 1
@export var move_accel : float = 0.6
@export var stop_drag : float = 0.9

var character_body : CharacterBody3D
var move_drag : float = 0.0
var move_dir : Vector3

func _ready() -> void:
	character_body = get_parent()
	move_drag = float(move_accel) / max_speed

func set_move_dir(new_move_dir: Vector3) -> void:
	move_dir = new_move_dir
	move_dir.y = 0.0
	move_dir = move_dir.normalized()

func jump() -> void:
	if character_body.is_on_floor():
		character_body.velocity.y = jump_force

func _physics_process(_delta : float) -> void:
	if Global.is_Running:
		max_speed = 5
	if character_body.velocity.y > 0.0 and character_body.is_on_ceiling():
		character_body.velocity.y = 0.0
	if not character_body.is_on_floor():
		character_body.velocity.y -= gravity * _delta
	
	var drag = move_drag
	if move_dir.is_zero_approx():
		drag = stop_drag
	
	var flat_velo = character_body.velocity
	flat_velo.y = 0.0
	character_body.velocity += move_accel * move_dir - flat_velo * drag
	
	character_body.move_and_slide()
