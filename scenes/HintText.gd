extends Node2D

var Text = ""

func _ready():
	$Label.text = Text
	$AnimationPlayer.play("Hint")

func _on_AnimationPlayer_animation_finished(_anim_name):
	call_deferred("queue_free")
