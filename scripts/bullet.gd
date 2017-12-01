extends KinematicBody2D

# class member variables go here, for example:
const PUSHBACK = 15
var velocity = Vector2()
var hit = preload("res://scenes/hit.tscn")
var last_x = 0
var travel = 0

func _ready():
	set_process(true)
	set_fixed_process(true)
	last_x = get_pos().x
	
func _fixed_process(delta):
	move(velocity)
	travel += abs(get_pos().x - last_x)
	last_x = get_pos().x
	if (travel > 400):
		var h = hit.instance()
		h.set_pos(get_pos())
		get_parent().add_child(h)
		queue_free()

func _on_Area2D_body_enter( body ):
	if (body.is_in_group("enemies")):
		body.velocity += velocity * PUSHBACK
		body.health -= 5
	var h = hit.instance()
	h.set_pos(get_pos())
	get_parent().add_child(h)
	queue_free()
