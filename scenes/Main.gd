extends Node2D

var PLAYERSCENE = preload("res://scenes/Player.tscn")
var STORYTEXTSCENE = preload("res://scenes/StoryText.tscn")
var SEAGULLSCENE = preload("res://scenes/Seagull.tscn")
onready var SeagullsNode = $Seagulls

onready var EffectsNode = $Effects
onready var TextNode = $UI/StoryTexts
onready var ColorTween = $UI/ColorRect/Tween
onready var StartPointFinder = $StartPointFinder
onready var StartPointFinderTween = $StartPointFinder/Tween

var Player
var PlayerCamera

var LastHeight
var CurrentZenBase
var Zen = 0.0
var StoryPoints = 0.0
var CamZoom = 0.5

var MaxZen = 1000.0
var MaxPoints = 800000.0

var IntroTexts = [
	"""Why?""",
	"""It’s been well over 10 years.""",
	"""Why doesn’t she want him there?""",
	"""Should I have just gone along with it?""",
	"""I need time to think..."""
]
var IntroTextPos = 0
var IntroGoingLeft
var FoundStartpoint = false

var StoryTexts = [
	"""Text 1""",
	"""Text 2""",
	"""Text 3""",
	"""Text 4""",
	"""Text 5""",
	"""Text 6""",
	"""Text 7""",
	"""Text 8""",
	"""Text 9""",
	"""Text 10""",
	"""Text 11""",
	"""Text 12""",
	"""Text 13""",
	"""Text 14""",
	"""Text 15""",
	"""Text 16""",
	"""Text 17""",
	"""Text 18""",
	"""Text 19""",
	"""Text 20""",
	"""Text 21""",
	"""Text 22""",
	"""Text 23""",
	"""Text 24""",
	"""Text 25""",
	"""Text 26""",
	"""Text 27""",
	"""Text 28""",
	"""Text 29""",
	"""Text 30"""
]
var TextInterval = 800000.0
var TextScore = 0.0
var TextNumber = 0

func _ready():
	randomize()
	TextInterval = 800000.0 / StoryTexts.size()
	PlayIntroText()

func PlayIntroText():
	if IntroTextPos < IntroTexts.size():
		var text = STORYTEXTSCENE.instance()
		text.Text = IntroTexts[IntroTextPos]
		text.set_position(Vector2(640.0, 256.0))
		text.connect("Done", self, "PlayIntroText")
		TextNode.add_child(text)
		IntroTextPos += 1
	else:
		IntroGoingLeft = randi() % 2 == 0
		var startPointStartPos = Vector2(-640.0, 690.0)
		var startPointEndPos = Vector2(3000.0, 690.0)
		if IntroGoingLeft:
			startPointEndPos = startPointStartPos
			startPointStartPos = Vector2(3000.0, 690.0)
		StartPointFinderTween.interpolate_property(StartPointFinder, "position", startPointStartPos, startPointEndPos, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		StartPointFinderTween.start()

func _process(delta):
	if Player:
		var playerHeight = Player.get_position().y
		Zen = max(CurrentZenBase - playerHeight, 0.0)
		if playerHeight < LastHeight:
			var pointsAdd = (LastHeight - playerHeight) * Zen
			LastHeight = playerHeight
			StoryPoints += pointsAdd
			TextScore += pointsAdd
			if TextScore >= TextInterval:
				TextScore -= TextInterval
				ShowStoryText()
		SetZenEffect(delta)

func ShowStoryText():
	if TextNumber < StoryTexts.size():
		var text = STORYTEXTSCENE.instance()
		text.Text = StoryTexts[TextNumber]
		TextNumber += 1
		text.set_position(Vector2(640.0, 256.0))
		TextNode.call_deferred("add_child", text)

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

func _on_StartPointFinder_area_entered(area):
	if not FoundStartpoint:
		FoundStartpoint = true
		var player = PLAYERSCENE.instance()
		player.set_position(StartPointFinder.get_position())
		player.connect("LostFocus", self, "PlayerLostFocus")
		$PlayerNode.call_deferred("add_child", player)
		ColorTween.interpolate_property($UI/ColorRect, "color", Color(0.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 0.0, 0.0), 5.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		ColorTween.start()
		yield(get_tree().create_timer(0.2), "timeout")
		Player = get_tree().get_nodes_in_group("PlayerBody")[0]
		PlayerCamera = get_tree().get_nodes_in_group("PlayerCamera")[0]
		LastHeight = Player.get_position().y
		CurrentZenBase = LastHeight
