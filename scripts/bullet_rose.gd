extends KinematicBody2D

# class member variables go here, for example:
const PUSHBACK = 15
var stop_factor = 0.9
var gravity = 2
var velocity = Vector2()
var hit = preload("res://scenes/hit.tscn")
onready var anim = get_node("AnimationPlayer")

func _ready():
	anim.play("main")
	anim.seek(randi() * 6)
	set_fixed_process(true)
	
func _fixed_process(delta):
	velocity.x *= stop_factor
	velocity.y += gravity
	var motion = velocity * delta
	move(motion)

func _on_Area2D_body_enter( body ):
	if (body.is_in_group("player")):
		body.velocity += velocity * PUSHBACK
		body.energy -= 10
		global.b_nohit = false
	var h = hit.instance()
	h.set_pos(get_pos())
	get_parent().add_child(h)
	queue_free()
