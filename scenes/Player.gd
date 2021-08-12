extends Node2D

signal LostFocus

onready var Body = $PlayerBody
onready var LeftHand = get_tree().get_nodes_in_group("LeftHand")[0]
onready var RightHand = get_tree().get_nodes_in_group("RightHand")[0]
var IsLeftHandActive = true

func _ready():
	SetHandsActive()

func _physics_process(delta):
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
