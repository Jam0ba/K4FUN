extends Node3D


var countSpawnedZom : int
@onready var point = $SpawnPoints/Point


@export var monster : PackedScene

func _ready() -> void:
	var monster_insta = monster.instantiate()
	add_child(monster_insta)
	monster_insta.global_position = point.global_position
	countSpawnedZom += 1
	print(countSpawnedZom)
	


func _on_spawn_timer_timeout():
	var monster_insta = monster.instantiate()
	add_child(monster_insta)
	monster_insta.global_position = point.global_position
	countSpawnedZom += 1
	print(countSpawnedZom)
