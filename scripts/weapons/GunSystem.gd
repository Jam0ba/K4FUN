class_name Weapon
extends Node3D

# Rotations
var currentRotation : Vector3
var targetRotation : Vector3

# Recoil vectors
@export var gun_Recoil : Vector3
@export var head : Node3D




@export var animation_player : AnimationPlayer
@onready var Shotgun_ShootSFX : AudioStreamPlayer = $AudioStream


@onready var clip_in_sound : AudioStreamPlayer = $clip_in_sound
@onready var mag_in_sound = $MagInSound
@onready var mag_out_sound = $MagOutSound


@export var bullet_emitter : Node3D
@export var fire_point : Node3D

@export var automatic : bool = false
@export var singleShot: bool = false


@export var damage : int = 5
@export var ammo : int = 30
@export var max_ammo : int
@export var refill_value : int
@export var attack_rate : float = 0.2
@export var is_DrawWeapon : bool

var last_attack_time : float = -999.0


signal fired
signal out_of_ammo
signal ammo_updated(ammo_amnt: int)

func _ready():
	bullet_emitter.set_damage(damage)
	



func set_bodies_to_exclude(bodies : Array) -> void:
	bullet_emitter.set_bodies_to_exclude(bodies)

func attack(input_just_pressed : bool, input_held : bool):
	if !is_DrawWeapon:
		if !automatic and !input_just_pressed:
			return
		if automatic and !input_held:
			return
		if ammo == 0:
			if input_just_pressed or input_held:
				#out_of_ammo.emit()
				if max_ammo > 0:
					animation_player.stop()
					animation_player.play("Reload")
				return animation_player
			else:
				animation_player.play("Idle", 0.2)
			
		var cur_time = Time.get_ticks_msec() / 1000.0
		if cur_time - last_attack_time < attack_rate:
			return
		head.New_Recoil(gun_Recoil)
		if ammo > 0:
			ammo -= 1
		bullet_emitter.global_transform = fire_point.global_transform
		bullet_emitter.fire()
		last_attack_time = cur_time
		mag_in_sound.stop()
		animation_player.play("Shoot")
		head.recoilFire(true)
		Shotgun_ShootSFX.play()
		fired.emit()
		animation_player.queue("Idle")
		if has_node("MuzzleFlash"):
			$MuzzleFlash.flash()
func set_active(a: bool) -> void:
	visible = a
	if !a:
		animation_player.stop()

func reload_weapon() -> void:
	var left = ammo - refill_value
	var needed = left * -1
	if needed < max_ammo:
		ammo += needed
		max_ammo -= needed
	else:
		ammo += max_ammo
		max_ammo = 0
	animation_player.queue("Idle")

func reload_shotgun() -> void:
	mag_in_sound.stop()
	if max_ammo > 0:
		if ammo != refill_value:
			ammo += 1
			mag_in_sound.play()
			max_ammo -= 1
		else:
			mag_in_sound.stop()
			is_DrawWeapon = false
			$Arms_Rig/Skeleton3D/BoneAttachment3D.visible = false
			animation_player.play("Idle", 0.2)
	else:
		mag_in_sound.stop()
		animation_player.play("Idle", 0.2)
		$Arms_Rig/Skeleton3D/BoneAttachment3D.visible = false
		#player out of ammo sound
func add_ammo(amnt : int):
	max_ammo += amnt
	ammo_updated.emit(max_ammo)


func play_mag_in() -> void:
	mag_in_sound.play()
func play_mag_out() -> void:
	mag_out_sound.play()
func play_clip_in() -> void:
	clip_in_sound.play()

func audio_stop() -> void:
	clip_in_sound.stop()
	mag_out_sound.stop()
	mag_in_sound.stop()



