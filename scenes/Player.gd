extends Node2D

onready var Body = $PlayerBody
onready var LeftHand = get_tree().get_nodes_in_group("LeftHand")[0]
onready var RightHand = get_tree().get_nodes_in_group("RightHand")[0]
var IsLeftHandActive = true

onready var Cam = $PlayerBody/Camera2D
var CamZoom = 0.5

func _ready():
	SetHandsActive()

func _physics_process(delta):
	Body.rotation = lerp_angle(Body.rotation, 0.0, delta * 10.0)

func _input(event):
	if event.is_action_pressed("mouse_click"):
		IsLeftHandActive = not IsLeftHandActive
		SetHandsActive()
	elif event.is_action_pressed("mouse_wheel_up"):
		CamZoom = max(CamZoom * 0.9, 0.2)
		Cam.zoom = Vector2(CamZoom, CamZoom)
	elif event.is_action_pressed("mouse_wheel_down"):
		CamZoom = min(CamZoom * 1.1, 1.5)
		Cam.zoom = Vector2(CamZoom, CamZoom)

func SetHandsActive():
	LeftHand.SetActive(IsLeftHandActive)
	RightHand.SetActive(not IsLeftHandActive)
