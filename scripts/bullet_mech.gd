extends KinematicBody2D

# class member variables go here, for example:
const PUSHBACK = 15
var damage = 15
var velocity = Vector2()
var hit = preload("res://scenes/hit.tscn")

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	set_rot(atan2(-velocity.y, velocity.x))
	move(velocity)

func _on_Area2D_body_enter( body ):
	if (body.is_in_group("player")):
		body.velocity += velocity * PUSHBACK
		body.energy -= damage
		global.b_nohit = false
	var h = hit.instance()
	h.set_pos(get_pos())
	get_parent().add_child(h)
	queue_free()
	
