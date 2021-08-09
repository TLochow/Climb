extends Node2D

var SEAGULLSCENE = preload("res://scenes/Seagull.tscn")
onready var SeagullsNode = $Seagulls

onready var Player = get_tree().get_nodes_in_group("PlayerBody")[0]
onready var PlayerCamera = get_tree().get_nodes_in_group("PlayerCamera")[0]

var LastHeight
var CurrentZenBase
var Zen = 0.0
var StoryPoints = 0.0
var CamZoom = 0.5

var MaxZen = 1000.0
var MaxPoints = 800000.0

func _ready():
	randomize()
	LastHeight = Player.get_position().y
	CurrentZenBase = LastHeight
	$Player.connect("LostFocus", self, "PlayerLostFocus")

func _process(delta):
	var playerHeight = Player.get_position().y
	Zen = max(CurrentZenBase - playerHeight, 0.0)
	if playerHeight < LastHeight:
		StoryPoints += (LastHeight - playerHeight) * Zen
		LastHeight = playerHeight
	SetZenEffect(delta)

func SetZenEffect(delta):
	var zenValue = min(Zen, MaxZen)
	var cameraZoom = range_lerp(zenValue, 0.0, MaxZen, 0.5, 0.1)
	CamZoom = lerp(CamZoom, cameraZoom, delta * 10.0)
	PlayerCamera.zoom = Vector2(CamZoom, CamZoom)

func PlayerLostFocus():
	CurrentZenBase = Player.get_position().y

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
