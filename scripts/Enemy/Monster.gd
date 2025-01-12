class_name Monster
extends CharacterBody3D

@onready var health_manager = $HealthManager
@onready var vision_manager = $VisionManager
@onready var alert_area = $AlertArea
@onready var enemy_mover = $enemy_mover
@onready var attack_emitter = $AttackEmitter
@onready var audio_stream = $AudioStream
@onready var navigation_agent_3d = $NavigationAgent3D




@onready var player = get_tree().get_first_node_in_group("player")


var walking_anim : Array[StringName] = ["Walking1", "Walking2", "Walking3"]
var last_rand : int
@export var animation_player : AnimationPlayer


@export var attack_range : float = 3.0
@export var damage : int = 15
var anim_speed : float
var running : bool = false

enum STATES {IDLE, ATTACK, DEAD}
var cur_state = STATES.IDLE


func _ready() -> void:
	walking_anim = ["Walking1", "Walking2", "Walking3"]
	last_rand = randi_range(0, 2)
	var hitboxes = find_children("*", "HitBox")
	for hitbox in hitboxes:
		hitbox.on_hurt.connect(health_manager.hurt)
	health_manager.died.connect(set_state.bind(STATES.DEAD))
	health_manager.gibbed.connect(queue_free)
	
	hitboxes.append(self)
	attack_emitter.set_bodies_to_exclude(hitboxes)
	attack_emitter.set_damage(damage)
	
	set_state(STATES.IDLE)

func hurt(damage_data : DamageData) -> void:
	health_manager.hurt(damage_data)
	animation_player.play("Hit", 0, 1.8)
	running = true
	_alert()

func _alert():
	if cur_state == STATES.IDLE:
		set_state(STATES.ATTACK)
		alert_near_monsters()

func alert_near_monsters():
	for b in alert_area.get_overlapping_bodies():
		if b is Monster:
			b._alert()

func set_state(state: STATES) -> void:
	if cur_state == STATES.DEAD:
		return
	cur_state = state
	
	match cur_state:
		STATES.IDLE:
			animation_player.play("Idle")
		STATES.DEAD:
			animation_player.play("Death", 0.2)
			collision_layer = 0
			collision_mask = 1
			enemy_mover.stop_moving()
			

func _process(_delta: float) -> void:
	match cur_state:
		STATES.IDLE:
			process_idle_state(_delta)
		STATES.ATTACK:
			process_attack_state(_delta)

func process_idle_state(_delta : float) -> void:
	if vision_manager.can_see_target(player):
		_alert()

func process_attack_state(_delta : float) -> void:
	var attacking = animation_player.current_animation == "Attack"
	var vec_to_player = player.global_position - global_position
	if !audio_stream.playing:
		audio_stream.playing = true
	if vec_to_player.length() <= attack_range:
		enemy_mover.stop_moving()
		if !attacking and vision_manager.is_facing_target(player):
			animation_player.play("Attack", 0.2, 4.5)
		elif !attacking:
			enemy_mover.set_facing_dir(vec_to_player)
	elif !attacking:
		enemy_mover.set_facing_dir(enemy_mover.move_dir)
		enemy_mover.move_to_point(player.global_position)
		if animation_player.current_animation == "Walking1":
			anim_speed = 2.2
		if animation_player.current_animation == "Walking2":
			anim_speed = 1.4
		if animation_player.current_animation == "Walking3":
			anim_speed = 1
		
		animation_player.play(walking_anim[last_rand], 0.2, anim_speed)
	
	
	
func do_attack() -> void:
	attack_emitter.fire()
	#add hit animation
	#add hit sound
