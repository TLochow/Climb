extends Area2D

var GRABAREASCENE = load("res://scenes/GrabArea.tscn")

var Tendency = 0.0

func _on_SpawnTimer_timeout():
	var pos = get_position()
	var parent = get_parent()
	if pos.y < 700.0:
		var numberOfAreas = 1
		if (randi() % 50) == 0:
			numberOfAreas += 1
		elif (randi() % 30) == 0 or get_overlapping_bodies().size() == 0:
			Tendency *= -1.0
		for i in range(numberOfAreas):
			if i > 0:
				Tendency *= -1.0
			var newArea = GRABAREASCENE.instance()
			var xChange = Tendency + rand_range(-16.0, 16.0)
			newArea.Tendency = clamp(Tendency + (xChange * 0.1), -8.0, 8.0)
			newArea.set_position(Vector2(pos.x + xChange, pos.y + 8.0))
			parent.call_deferred("add_child", newArea)
