extends Node

@onready var guns = %Weapon_Holder
@onready var player = $"../../.."
@onready var parent = $"../.."
@onready var los_ray_cast_3d = $LOSRayCast3D
@export var weapon_rotation_amount : float = 0.001
@export var weapon_rotation_amount_y : float = 0.003
@export var invert_weapon_sway : bool = false

var player_inventory
@onready var weapons = %Weapons.get_children()
var weapons_unlocked = []
var cur_slot : int = 0
var last_slot : int = 0
var cur_weapon = null
var is_DrawWeapon : bool = true
var mouse_motion : Vector2

func _ready() -> void:
	
	for _i in range(weapons.size()):
		weapons_unlocked.append(false)
	weapons_unlocked[0] =  true
	switch_to_weapon_slot(0)

func enable_weapon(weapon: Weapon):
	if weapon == null:
		return
	var weapon_ind = weapon.get_index()
	var weapon_already_unlocked = weapons_unlocked[weapon_ind]
	weapons_unlocked[weapon_ind] = true
	if !weapon_already_unlocked:
		switch_to_weapon_slot(weapon_ind)

func attack(input_just_pressed : bool, input_held : bool):
	if cur_weapon is Weapon:
		cur_weapon.attack(input_just_pressed, input_held)


func disable_all_weapons() -> void:
	for weapon in weapons:
		if has_method("set_active"):
			weapon.set_active(false)
		else:
			weapon.hide()

func switch_to_previous_weapon() -> void:
	var wrap = wrapi(cur_slot + 1, last_slot, weapons.size())
	switch_to_weapon_slot(wrap)
	weapons[cur_slot].animation_player.play("Draw") 
	weapons[cur_slot].is_DrawWeapon = true
	weapons[cur_slot].animation_player.queue("Idle")

func switch_to_weapon_slot(slot_ind : int) -> bool:
	if slot_ind >= weapons.size() or slot_ind < 0:
		return false
	if weapons_unlocked.size() == 0 or !weapons_unlocked[slot_ind]:
		return false
	disable_all_weapons()
	cur_slot = slot_ind
	cur_weapon = weapons[cur_slot]
	if has_method("set_active"):
		cur_weapon.set_active(true)
	else:
		weapons[cur_slot].animation_player.play("Draw")
		weapons[cur_slot].is_DrawWeapon = true
		weapons[cur_slot].animation_player.queue("Idle")
		cur_weapon.show()
	return true

func _physics_process(_delta : float) -> void:
	weapon_sway(_delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion = -event.relative
	if event.is_action_pressed("reload"):
		if weapons[cur_slot].ammo != weapons[cur_slot].refill_value and weapons[cur_slot].max_ammo > 0:
			if !weapons[cur_slot].animation_player.current_animation == "Reload":
				weapons[cur_slot].animation_player.stop()
				weapons[cur_slot].animation_player.play("Reload")



func weapon_sway(delta: float) -> void:
	mouse_motion = lerp(mouse_motion, Vector2.ZERO, 10.0 * delta)
	guns.rotation.x = lerp(guns.rotation.x, mouse_motion.y * weapon_rotation_amount_y * (-1 if invert_weapon_sway else 1), 6 * delta)
	guns.rotation.y = lerp(guns.rotation.y, mouse_motion.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)

func get_weapon_from_pick_up(weapon_type):
	match weapon_type:
		Pickup.WEAPONS.GLOCK:
			return $Weapons/Glock_Arms
		Pickup.WEAPONS.M4:
			return $Weapons/M4_n_Arms
		Pickup.WEAPONS.SHOTGUN:
			return $Weapons/ShotGun_n_Arms
	return null
