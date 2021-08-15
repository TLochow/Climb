extends Node2D

signal LostFocus

onready var Body = $PlayerBody
onready var LeftHand = get_tree().get_nodes_in_group("LeftHand")[0]
onready var RightHand = get_tree().get_nodes_in_group("RightHand")[0]
var IsLeftHandActive = true

var FixedBodyPos

func _ready():
	SetHandsActive()

func _physics_process(delta):
	if FixedBodyPos:
		Body.set_position(FixedBodyPos)
		Body.rotation = 0.0
	else:
		Body.rotation = lerp_angle(Body.rotation, 0.0, delta * 100.0)

func _input(event):
	if event.is_action_pressed("mouse_click"):
		var canGrab
		if IsLeftHandActive:
			canGrab = LeftHand.CanGrab()
		else:
			canGrab = RightHand.CanGrab()
		if canGrab:
			IsLeftHandActive = not IsLeftHandActive
			SetHandsActive()

func SetHandsActive():
	LeftHand.SetActive(IsLeftHandActive)
	RightHand.SetActive(not IsLeftHandActive)

func LooseFocus():
	emit_signal("LostFocus")

func Hit():
	LooseFocus()
	if IsLeftHandActive:
		LeftHand.LooseGrip()
	else:
		RightHand.LooseGrip()

func FadeArms():
	var fader = $ArmFader
	fader.interpolate_property($LeftArm, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 2.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	fader.interpolate_property($RightArm, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 2.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	fader.start()

func FixBodyPos():
	FixedBodyPos = Body.get_position()
