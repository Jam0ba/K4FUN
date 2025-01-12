extends BulletEmitter

@export var burst_count : int = 5


func fire():
	for _i in range(burst_count):
		super()
