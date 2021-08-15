extends RigidBody2D

var HINTTEXTSCENE = preload("res://scenes/HintText.tscn")

export(bool) var IsLeftHand = false

onready var Player = get_tree().get_nodes_in_group("Player")[0]
onready var FixedPos = get_global_position()
onready var MountainDetector = $MountainDetector
onready var RegainControlTimer = $RegainControlTimer
onready var HandSprite = $Sprite

var OtherHand
var Active = false
var MaxDist = 30.0
var TakesInput = true
var MaxCooldown = 2.0
var GrabCooldown = MaxCooldown
var HandColor = 0.5

func _ready():
	if IsLeftHand:
		OtherHand = get_tree().get_nodes_in_group("RightHand")[0]
	else:
		OtherHand = get_tree().get_nodes_in_group("LeftHand")[0]

func _physics_process(delta):
	var pos = get_global_position()
	if Active:
		if TakesInput:
			GrabCooldown = max(GrabCooldown - delta, 0.0)
			var mousePos = .get_global_mouse_position()
			var otherHandPos = OtherHand.get_global_position()
			var dir = mousePos - otherHandPos
			if dir.length() > MaxDist:
				dir = dir.normalized() * MaxDist
			linear_velocity = ((otherHandPos + dir) - pos) * 2.0
	else:
		linear_velocity = FixedPos - pos
		GrabCooldown = MaxCooldown
	var targetColor = 1.0
	if GrabCooldown > 0.0:
		targetColor = 0.25
	HandColor = lerp(HandColor, targetColor, delta * 10.0)
	HandSprite.modulate = Color(HandColor, HandColor, HandColor, 1.0)

func SetActive(value):
	Active = value
	if not Active:
		FixedPos = get_global_position()
		GrabCooldown = MaxCooldown

func CanGrab():
	if not TakesInput:
		return false
	var canGrab = true
	if GrabCooldown > 0.1:
		canGrab = false
		ShowHintText("Too early!")
	elif MountainDetector.get_overlapping_areas().size() == 0:
		canGrab = false
		ShowHintText("Missed!")
	if not canGrab:
		Player.LooseFocus()
		LooseGrip()
	return canGrab

func ShowHintText(text):
	var hintText = HINTTEXTSCENE.instance()
	hintText.set_position(get_global_position())
	hintText.Text = text
	get_tree().root.call_deferred("add_child", hintText)

func LooseGrip():
	if TakesInput:
		TakesInput = false
		GrabCooldown = MaxCooldown
		RegainControlTimer.start()

func _on_RegainControlTimer_timeout():
	TakesInput = true
