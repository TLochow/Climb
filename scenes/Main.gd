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
	"""When do you think the most?""",
	"""When can you really focus on the problems you have to solve?""",
	"""For me it's when I climb.""",
	"""On the cliff of a mountain.""",
	"""When I have the least distractions.""",
	"""When I can pace myself and don't rush things.""",
	"""And right now?""",
	"""I need to think."""
]
var IntroTextPos = 0
var IntroGoingLeft
var FoundStartpoint = false

var StoryTexts = [
	"""What do I do?""",
	"""I really love her_, but I don't think I can do this.""",
	"""I mean... Am I really at fault here?""",
	"""And what does she expect, just laying this on me?!""",
	"""That I just act like it's no big deal?!""",
	"""Like, seriously. What was she expecting?""",
	"""Well_, I guess it's not really her fault.""",
	"""You can't exactly choose how you feel.""",
	"""Or who you are.""",
	"""And I can't understand how_ she feels.""",
	"""I can't deny her, how she feels.""",
	"""Oh gosh, how DOES she feel about us?""",
	"""This can't be easy for her, either.""",
	"""She said she wanted to stay together.""",
	"""But I just don't know if I can do that!""",
	"""Is that wrong?""",
	"""No,_ I don't think anyone could blame me for that.""",
	"""And I think she - ___ HE - would agree.""",
	"""But I do love her_, him_, whatever!""",
	"""At least I do now.""",
	"""I don't think I'm gay.""",
	"""Would I stop loving_ h_-her as__ he transitions?""",
	"""Maybe I should just accept__ him for who he is?""",
	"""CAN I accept_ him?___ As a boyfriend?""",
	"""I guess I should at least try?""",
	"""And see how our relationship changes?""",
	"""Maybe I will stop loving_ him along the way, maybe I won't.""",
	"""I guess we'll just have to wait and see.""",
	"""I can't just throw away what we have.""",
	"""I owe it to us to at least try."""
]
var TextInterval = 800000.0
var TextScore = 0.0
var TextNumber = 0
var CanShowText = true

var Endings = {
	1:
		[["Wow, what a shitty day!", 2],
		["First the thing with my girlfriend.", 2],
		["And then I couldn't even climb in peace!", 2],
		["Seriously, what the f#*k!?", 2]
		],
	6:
		[["Angery!", 2]
		],
	11:
		[["It's not her fault.", 2]
		],
	16:
		[["Is it my fault?", 2]
		],
	24:
		[["Should I try?", 2]
		],
	100:
		[["I SHOULD try!", 2]
		]
	}

func _input(event):
	if event.is_action_pressed("restart"):
		Restart()
	elif event.is_action_pressed("ui_cancel"):
		EndGame()

func _ready():
	randomize()
	TextInterval = 800000.0 / StoryTexts.size()
	PlayIntroText()

func Restart():
	get_tree().change_scene("res://scenes/Main.tscn")

func EndGame():
	get_tree().quit()

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
			if TextScore >= TextInterval and CanShowText:
				CanShowText = false
				TextScore -= TextInterval
				ShowStoryText()
		SetZenEffect(delta)

func ShowStoryText():
	if TextNumber < StoryTexts.size():
		var text = STORYTEXTSCENE.instance()
		text.Text = StoryTexts[TextNumber]
		TextNumber += 1
		text.set_position(Vector2(640.0, 256.0))
		text.connect("Done", self, "TextFinished")
		TextNode.call_deferred("add_child", text)

func TextFinished():
	CanShowText = true

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

func _on_StartPointFinder_area_entered(_area):
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
