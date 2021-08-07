extends Node2D

var SEAGULLSCENE = preload("res://scenes/Seagull.tscn")
onready var SeagullsNode = $Seagulls

func _ready():
	randomize()

func _on_SeagullTimer_timeout():
	var seagull = SEAGULLSCENE.instance()
	var spawnsLeft = randi() % 2 == 0
	seagull.GoesLeft = not spawnsLeft
	var spawnHeight = rand_range(-450.0, 600.0)
	var spawnWidth = 3300.0
	if spawnsLeft:
		spawnWidth = -1000.0
	seagull.set_position(Vector2(spawnWidth, spawnHeight))
	SeagullsNode.add_child(seagull)
