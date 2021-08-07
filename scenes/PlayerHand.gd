extends RigidBody2D

export(bool) var IsLeftHand = false

onready var FixedPos = get_global_position()

var OtherHand
var Active = false
var MaxDist = 30.0

func _ready():
	if IsLeftHand:
		OtherHand = get_tree().get_nodes_in_group("RightHand")[0]
	else:
		OtherHand = get_tree().get_nodes_in_group("LeftHand")[0]

func _physics_process(delta):
	var pos = get_global_position()
	if Active:
		var mousePos = .get_global_mouse_position()
		var otherHandPos = OtherHand.get_global_position()
		var dir = mousePos - otherHandPos
		if dir.length() > MaxDist:
			dir = dir.normalized() * MaxDist
		linear_velocity = ((otherHandPos + dir) - pos) * 2.0
	else:
		var dir = FixedPos - pos
		linear_velocity = dir

func SetActive(value):
	Active = value
	if not Active:
		FixedPos = get_global_position()
