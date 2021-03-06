extends Node2D

signal Done

onready var TextBox = $Label
onready var TextTimer = $Timer
onready var FadeTween = $Tween

var Text
var TextLength
var Position = 0
var Timeout = 0

func _ready():
	TextLength = Text.length()
	TextTimer.start()

func _on_Timer_timeout():
	if Timeout > 0:
		Timeout -= 1
	elif Position < TextLength:
		var nextChar = Text.substr(Position, 1)
		if nextChar == '_':
			Timeout = 10
		else:
			TextBox.text = TextBox.text + nextChar
		Position += 1
	else:
		TextTimer.stop()
		FadeTween.interpolate_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 2.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		FadeTween.start()

func _on_Tween_tween_all_completed():
	emit_signal("Done")
	call_deferred("queue_free")
