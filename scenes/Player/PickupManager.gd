extends Area3D

@onready var health_manager = %HealthManager
@onready var weapon_holder = %Weapon_Holder
@onready var weapons = %Weapons


# Called when the node enters the scene tree for the first time.
func _ready():
	area_entered.connect(on_area_enter)
	
func on_area_enter(pickup: Area3D):
	var delete_on_pickup = true
	if pickup is Pickup:
		match pickup.pickup_type:
			Pickup.PICKUP_TYPES.HEALTH:
				if health_manager.cur_health < health_manager.max_health:
					health_manager.heal(pickup.pickup_amnt)
				else:
					delete_on_pickup = false
			Pickup.PICKUP_TYPES.AMMO:
				var weapon : = weapons.get_children()
				for i in weapon:
					if i is Weapon:
						i.add_ammo(pickup.pickup_amnt)
			Pickup.PICKUP_TYPES.WEAPON:
				var weapon : Weapon = weapon_holder.get_weapon_from_pick_up(pickup.weapon_type)
				weapon_holder.enable_weapon(weapon)
				
	if delete_on_pickup:
		pickup.Pickuped()
