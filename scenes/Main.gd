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
	0:
		[["Wow, what a shitty day!", 2],
		["First the thing with my girlfriend.", 2],
		["And then I couldn't even climb in peace!", 2],
		["Seriously, what the f#*k!?", 2]
		],
	2:
		[["Dialing__.__.__.", 2],
		["H-hey babe.", 1],
		["__Hi.", 3],
		["So,_ did you have time to think?", 1],
		["Yes.", 3],
		["And? What do you think?", 1],
		["*sigh*", 3],
		["Listen,_ I can't handle this.", 3],
		["And quite frankly I find it unfair of you to just come out of the blue with this.", 3],
		["__I_._._._ I understand.", 1],
		["But you're not gonna change your mind?", 3],
		["What?_ NO! Of course not.", 1],
		["This is not something where I can just change my mind!", 1],
		["I didn't chose for this to happen!", 1],
		["For me to be like I am!", 1],
		["This is not something that I can change!", 1],
		["And if you can't accept that then I guess there is no hope for us!", 1],
		["FINE!", 3],
		["So that's it then?", 3],
		["I'm afraid so.", 1],
		["Okay, then I'll pack my things and leave!", 3],
		["FINE.", 1],
		["*CLICK*", 2]
		],
	7:
		[["Dialing__.__.__.", 2],
		["H-hey babe.", 1],
		["__Hi.", 3],
		["So,_ did you have time to think?", 1],
		["Yes.", 3],
		["And? What do you think?", 1],
		["*sigh*", 3],
		["Listen,_ I'm_ not sure about this.", 3],
		["I don't know what to do.", 3],
		["And I realize this isn't your fault.", 3],
		["I just___, yeah, I don't know.", 3],
		["And_ will you be okay?", 1],
		["Will_ we be okay?", 1],
		["I___ - I don't think so_, sorry.", 3],
		["I know you can't change who you are...", 3],
		["But_ please realize, that I can't change myself either.", 3],
		["I love you._ But I don't think I can keep loving you.", 3],
		["I__ understand.", 1],
		["It would be unfair of me to expect otherwise.", 1],
		["But we'll stay friends, right?", 1],
		["Of course!", 3],
		["It might be a bit awkward, but we'll manage.", 3],
		["___Thanks.", 1],
		["So__, I guess I'll see you at home?", 1],
		["Yeah, see you at home.___ Bye.", 3],
		["Bye.", 1],
		["*Click*", 2]
		],
	12:
		[["Dialing__.__.__.", 2],
		["H-hey babe.", 1],
		["__H-Hello.", 3],
		["You sound... nervous?", 1],
		["Should I not be nervous?", 3],
		["I guess it's somewhat justified.", 1],
		["___So_, what_ uhm_ what do you think?__ About us?", 1],
		["I_ - I'm not sure. I_ - I am not really into___ men.", 3],
		["Is that bad?", 3],
		["Should._._._ Should I feel bad?", 3],
		["___*sigh*", 1],
		["No.", 1],
		["No, you shouldn't feel bad.", 1],
		["I can't expect from you to change who you love.", 1],
		["But___ does that mean that we can't stay together?", 1],
		["I_ - I guess so.", 3],
		["Sorry.", 3],
		["Don't be.", 1],
		["It's not your fault.", 1],
		["But we'll stay friends, right?", 1],
		["Of course!", 3],
		["It might be a bit awkward, but we'll manage.", 3],
		["___Thanks.", 1],
		["So__, I guess I'll see you at home?", 1],
		["Yeah, see you at home.___ Bye.", 3],
		["Bye.", 1],
		["*Click*", 2]
		],
	17:
		[["Dialing__.__.__.", 2],
		["H-hey babe.", 1],
		["H-hey.", 3],
		["So,_ did you have time to think?", 1],
		["Yes.", 3],
		["And? What do you think?", 1],
		["*sigh*", 3],
		["There is no going back on this, is there?", 3],
		["What?_ NO! Of course not.", 1],
		["Yeah_, sorry. Stupid question.", 3],
		["Listen__, I__ - I think we_ could give it a try.", 3],
		["Wha-?__ Really?", 1],
		["Yes, really.", 3],
		["Oh, babe! I...", 1],
		["You don't know how happy that makes me!", 1],
		["Heh, I might have a bit of an idea.", 3],
		["But listen. I can't promise you it will work out.", 3],
		["I'm still not sure how this will go.", 3],
		["If_ - If I can do it.", 3],
		["No, of course not.", 1],
		["I can't expect that from you.", 1],
		["But that you are willing to try already means so much to me.", 1],
		["I can tell. But_, it's the least I can do.", 3],
		["It really isn't, and you know that.", 1],
		["If you say so.", 3],
		["Well, I guess it's time for me to get off this mountain.", 3],
		["See you in a bit.", 3],
		["See you! Love you.", 1],
		["I___ love you too.", 3],
		["*Click*", 2]
		],
	25:
		[["Dialing__.__.__.", 2],
		["H-hey babe.", 1],
		["Hey babe.", 3],
		["So,_ did you have time to think?", 1],
		["Yes.", 3],
		["And?_ What do you think?", 1],
		["I think we should give it a try.", 3],
		["Wha-?__ Really?", 1],
		["Haha, Yes, really.", 3],
		["Oh, babe! I...", 1],
		["You don't know how happy that makes me!", 1],
		["Heh, I might have a bit of an idea.", 3],
		["___I must confess. I'm a bit excited as well.", 3],
		["Oh, really?", 1],
		["Yeah.", 3],
		["Listen_, I can't promise anything.", 3],
		["Of course not.", 1],
		["But I wanna see where this leads.", 3],
		["___Oh gosh, it'll be awkward when we tell our friends.", 3],
		["Oh, yeah._ Definitively.", 1],
		["But we'll manage.", 3],
		["You really are the best.", 1],
		["I know, you are very lucky to have me.", 3],
		["Ha. Ha.", 1],
		["No, but you are right. I'm extremely lucky.", 1],
		["So, what now?", 1],
		["Well, I guess it's time for me to get off this mountain.", 3],
		["Hihi.", 1],
		["See you in a bit.", 3],
		["See you then! I love you.", 1],
		["Love you too, babe.", 3],
		["*Click*", 2]
		]
	}
onready var EndTween = $EndTrigger/EndTween
var GameEnded = false
var EndingStarted = false
var GameOver = false
var UsedEnding
var LeftHand
var RightHand
var PlayerMainNode
var EndingTextNumber = 0

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
		var yPos = 690.0
		var startPointStartPos = Vector2(-640.0, yPos)
		var startPointEndPos = Vector2(3000.0, yPos)
		if IntroGoingLeft:
			startPointEndPos = startPointStartPos
			startPointStartPos = Vector2(3000.0, yPos)
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
	if EndingStarted:
		if TextScore < TextInterval and CanShowText:
			ShowCreditsText()

func ShowStoryText():
	if TextNumber < StoryTexts.size():
		var text = STORYTEXTSCENE.instance()
		text.Text = StoryTexts[TextNumber]
		TextNumber += 1
		text.set_position(Vector2(640.0, 256.0))
		text.connect("Done", self, "TextFinished")
		TextNode.call_deferred("add_child", text)

func ShowCreditsText():
	CanShowText = false
	if EndingTextNumber < UsedEnding.size():
		var text = STORYTEXTSCENE.instance()
		text.Text = UsedEnding[EndingTextNumber][0]
		var posIndex = UsedEnding[EndingTextNumber][1]
		if posIndex == 1:
			text.set_position(Vector2(340.0, 256.0))
		elif posIndex == 2:
			text.set_position(Vector2(640.0, 256.0))
		else:
			text.set_position(Vector2(940.0, 256.0))
		text.connect("Done", self, "TextFinished")
		TextNode.call_deferred("add_child", text)
		EndingTextNumber += 1
	else:
		GameOver = true
		ColorTween.interpolate_property($UI/ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 1.0), 5.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		ColorTween.start()

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

func _on_EndTrigger_body_entered(_body):
	if not GameEnded:
		GameEnded = true
		$Seagulls/SeagullTimer.stop()
		LeftHand = get_tree().get_nodes_in_group("LeftHand")[0]
		RightHand = get_tree().get_nodes_in_group("RightHand")[0]
		PlayerMainNode = get_node("PlayerNode/Player")
		PlayerMainNode.FadeArms()
		LeftHand.SetActive(true)
		RightHand.SetActive(true)
		LeftHand.TakesInput = false
		RightHand.TakesInput = false
		var endPos = $EndTrigger.get_position() - PlayerMainNode.get_position()
		EndTween.interpolate_property(LeftHand, "position", LeftHand.get_position(), endPos, 2.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		EndTween.interpolate_property(RightHand, "position", RightHand.get_position(), endPos, 2.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		EndTween.interpolate_property(Player, "position", Player.get_position(), endPos, 2.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		EndTween.start()

func _on_EndTween_tween_all_completed():
	PlayerMainNode.FixBodyPos()
	LeftHand.SetActive(false)
	RightHand.SetActive(false)
	EndingStarted = true
	
	for end in Endings.keys():
		if TextNumber >= end:
			UsedEnding = Endings[end]

func _on_Tween_tween_all_completed():
	if GameOver:
		Restart()
