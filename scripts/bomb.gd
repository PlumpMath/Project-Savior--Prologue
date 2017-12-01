extends KinematicBody2D

# class member variables go here, for example:
const PUSHBACK = 15
var damage = 40
var velocity = Vector2()
var hit = preload("res://scenes/hit.tscn")
var bullet = preload("res://scenes/bullet_mech.tscn")

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	velocity.y += 0.1
	move(velocity)
	
func create_bullet(x, y):
	var b = bullet.instance()
	b.set_pos(Vector2(get_pos().x, get_pos().y - 8))
	b.velocity = (Vector2(x, y))
	get_parent().add_child(b)

func _on_Area2D_body_enter( body ):
	if (body.is_in_group("player")):
		body.velocity += velocity * PUSHBACK
		body.energy -= damage
		global.b_nohit = false
	else:
		create_bullet(-3, 0)
		create_bullet(-3, -1)
		create_bullet(-3, -2)
		create_bullet(-2, -2)
		create_bullet(-1, -2)
		create_bullet(0, -2)
		create_bullet(1, -2)
		create_bullet(2, -2)
		create_bullet(3, -2)
		create_bullet(3, -1)
		create_bullet(3, 0)
	var h = hit.instance()
	h.set_pos(get_pos())
	get_parent().add_child(h)
	queue_free()
	
