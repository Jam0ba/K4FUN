extends Control

func _draw() -> void:
	
	#Draw line X
	draw_line(Vector2(4, 0), Vector2(12, 0), Color.GREEN, 1.1)
	draw_line(Vector2(-4, 0), Vector2(-12, 0), Color.GREEN, 1.1)
	
	#Draw line Y
	draw_line(Vector2(0, 4), Vector2(0, 12), Color.GREEN, 1.1)
	draw_line(Vector2(0, -4), Vector2(0, -12), Color.GREEN, 1.1)
