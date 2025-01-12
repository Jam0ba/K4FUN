extends CanvasLayer

@onready var ammo = $Control/VBoxContainer/Ammo
@onready var fps = $Control/VBoxContainer2/FPS
@onready var progress_bar = $Control/VBoxContainer3/ProgressBar


@onready var weapon_holder = %Weapon_Holder
@onready var weapons = %Weapons.get_children()
@onready var health_manager = %HealthManager



func _process(_delta: float) -> void:
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	ammo.text = "Ammo: " + str(weapons[weapon_holder.cur_slot].ammo) + " / " + str((weapons[weapon_holder.cur_slot].max_ammo))
	progress_bar.value = health_manager.cur_health
