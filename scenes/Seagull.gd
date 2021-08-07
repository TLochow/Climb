extends Area2D

onready var Speed = rand_range(25.0, 50.0)

var GoesLeft = false

func _ready():
	$Sprite.flip_h = not GoesLeft
	$AnimationPlayer.play("Fly")

func _process(delta):
	var pos = get_position()
	if GoesLeft:
		pos.x -= Speed * delta
		if pos.x < -1000.0:
			call_deferred("queue_free")
	else:
		pos.x += Speed * delta
		if pos.x > 3300.0:
			call_deferred("queue_free")
	set_position(pos)
