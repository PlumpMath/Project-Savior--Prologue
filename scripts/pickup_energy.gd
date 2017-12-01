extends KinematicBody2D

# class member variables go here, for example:
var boom = preload("res://scenes/boom.tscn")
onready var anim = get_node("AnimationPlayer")

func _ready():
	set_process(true)
	anim.play("main")
	anim.set_speed(2)

func _on_Area2D_body_enter( body ):
	if (body.is_in_group("player")):
		body.energy = body.max_energy
		var b = boom.instance()
		get_parent().add_child(b)
		b.set_pos(get_pos())
		b.set_speed(2)
		queue_free()
