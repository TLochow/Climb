extends RigidBody2D

export(bool) var IsLeftHand = false

onready var Player = get_tree().get_nodes_in_group("Player")[0]
onready var FixedPos = get_global_position()
onready var MountainDetector = $MountainDetector
onready var RegainControlTimer = $RegainControlTimer

var OtherHand
var Active = false
var MaxDist = 30.0
var TakesInput = true

func _ready():
	if IsLeftHand:
		OtherHand = get_tree().get_nodes_in_group("RightHand")[0]
	else:
		OtherHand = get_tree().get_nodes_in_group("LeftHand")[0]

func _physics_process(_delta):
	var pos = get_global_position()
	if Active:
		if TakesInput:
			var mousePos = .get_global_mouse_position()
			var otherHandPos = OtherHand.get_global_position()
			var dir = mousePos - otherHandPos
			if dir.length() > MaxDist:
				dir = dir.normalized() * MaxDist
			linear_velocity = ((otherHandPos + dir) - pos) * 2.0
	else:
		linear_velocity = FixedPos - pos

func SetActive(value):
	Active = value
	if not Active:
		FixedPos = get_global_position()

func CanGrab():
	if not TakesInput:
		return false
	var canGrab = MountainDetector.get_overlapping_areas().size() > 0
	if not canGrab:
		Player.LooseFocus()
		LooseGrip()
	return canGrab

func LooseGrip():
	if TakesInput:
		TakesInput = false
		RegainControlTimer.start()

func _on_RegainControlTimer_timeout():
	TakesInput = true
