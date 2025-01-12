extends RigidBody3D


@export var start_move_speed : float = 5.0
@export var drag : float = 0.01
@export var velo_retained_on_bounce : float = 0.8

@onready var gib_graphics = $Graphics.get_children()
@onready var blood_particles = $BloodParticles

func _ready() -> void:
	for g in gib_graphics:
		g.hide()
	gib_graphics[randi_range(0, gib_graphics.size()-1)].show()
	randomize_rotation()
	angular_velocity = -global_transform.basis.y * randf_range(0.0, start_move_speed)

func _physics_process(delta: float) -> void:
	angular_velocity += -angular_velocity * drag + Vector3.DOWN  * delta
	
	var collision = move_and_collide(angular_velocity * delta)
	if collision:
		var d = angular_velocity
		var n = collision.get_normal()
		var r = d - 2 * d.dot(n) * n
		angular_velocity = r * velo_retained_on_bounce
		var velo_magnitude = angular_velocity.length()
		if velo_magnitude > 1.0:
			randomize_rotation()
		if velo_magnitude < 0.5:
			set_physics_process(false)

func randomize_rotation():
	rotation.x = randf_range(0.0, TAU)
	rotation.y = randf_range(0.0, TAU)
	rotation.z = randf_range(0.0, TAU)

func hurt(damage_data: DamageData) -> void:
	blood_particles.emitting = true
	$Graphics.hide()
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _on_timer_timeout():
	blood_particles.emitting = true
	queue_free()
