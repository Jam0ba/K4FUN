extends BulletEmitter

@onready var ray_cast_3d = $RayCast3D
@export var BULLET_HIT_EFFECKT : PackedScene

func set_bodies_to_exclude(bodies : Array) -> void:
	super(bodies)
	
	for body in bodies:
		ray_cast_3d.add_exception(body)

func fire():
	ray_cast_3d.enabled = true
	ray_cast_3d.force_raycast_update()
	if ray_cast_3d.is_colliding():
		if ray_cast_3d.get_collider().has_method("hurt"):
			var damage_data = DamageData.new()
			damage_data.amount = damage
			damage_data.hit_pos = ray_cast_3d.get_collision_point()
			ray_cast_3d.get_collider().hurt(damage_data)
		else:
			var hit_effect_ins : Node3D = BULLET_HIT_EFFECKT.instantiate()
			get_tree().root.add_child(hit_effect_ins)
			var hit_pos : Vector3 = ray_cast_3d.get_collision_point()
			var hit_normal : Vector3 = ray_cast_3d.get_collision_normal()
			var loot_at_pos : Vector3 = hit_pos + hit_normal
			hit_effect_ins.global_position = hit_pos
			if hit_normal.is_equal_approx(Vector3.UP) or hit_normal.is_equal_approx(Vector3.DOWN):
				hit_effect_ins.look_at(loot_at_pos, Vector3.RIGHT)
			else:
				hit_effect_ins.look_at(loot_at_pos)
	ray_cast_3d.enabled = false
	super()
