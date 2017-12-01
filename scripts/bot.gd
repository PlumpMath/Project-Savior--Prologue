extends KinematicBody2D

# class member variables go here, for example:
const NONE_THRESHOLD = 480
const SHOOT_THRESHOLD = 128
const WALK_THRESHOLD = 64
var shoot_time = 30
var move_speed = 2
var max_speed = 200
var max_move_speed = 50
var jump = 200
var gravity = 10
var max_gravity = 200
var stop_factor = 0.1
var stop_threshold = 2
var shoot_timer = 0
var health = 30
var velocity = Vector2()
var on_floor = false
var jumped = false
var state = "shoot"
var bullet = preload("res://scenes/bullet_bot.tscn")
var pickup_energy = preload("res://scenes/pickup_energy.tscn")
var boom = preload("res://scenes/boom.tscn")
onready var player = get_node("../../player")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
	
func _ready():
	if (global.hard_mode):
		shoot_time = 20
	add_to_group("enemies")
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (get_pos().distance_to(player.get_pos()) < NONE_THRESHOLD):
		if (state == "walk" || state == "jump"):
			if (get_pos().x > player.get_pos().x):
				velocity.x -= move_speed
			else:
				velocity.x += move_speed
		if (state == "idle" || state == "shoot"):
			velocity.x *= stop_factor
			if (velocity.x < stop_threshold && velocity.x > -stop_threshold):
				velocity.x = 0
				
		if (on_floor):
			if (state == "shoot" || get_pos().distance_to(player.get_pos()) > SHOOT_THRESHOLD):
				state = "shoot"
				if (shoot_timer <= 0):
					var b = bullet.instance()
					var shoot_pos = Vector2(get_pos().x, get_pos().y - 10)
					b.velocity = (player.get_pos() - shoot_pos).normalized()
					b.set_pos(shoot_pos)
					get_parent().add_child(b)
					shoot_timer = shoot_time
				else:
					shoot_timer -= 1
			elif (state == "jump" || get_pos().distance_to(player.get_pos()) < 255):
				state = "jump"
				velocity.y = -jump
				on_floor = false
			
		if (state == "shoot"):
			if (anim.get_current_animation() != "shoot"):
				anim.seek(0)
				anim.play("shoot")
			elif (sprite.get_frame() >= 1):
				anim.set_speed(0)
		elif (!on_floor && abs(velocity.y) > 100 || state == "jump" || velocity.x != 0):
			if (anim.get_current_animation() != "walk"):
				anim.set_speed(1)
				anim.seek(0)
				anim.play("walk")
		elif (anim.get_current_animation() != "idle"):
			anim.set_speed(1)
			anim.seek(0)
			anim.play("idle")
			
		if (velocity.x > max_speed):
			velocity.x = max_speed
		elif (velocity.x < -max_speed):
			velocity.x = -max_speed
		if (velocity.x > max_move_speed):
			velocity.x -= move_speed
		elif (velocity.x < -max_move_speed):
			velocity.x += move_speed
		
		if (!on_floor):
			velocity.y += gravity
		if (velocity.y > max_gravity):
			velocity.y = max_gravity
		
		var motion = velocity * delta
		move(motion)
		
		var was_on_floor = on_floor
		on_floor = false
		if (is_colliding()):
			var n = get_collision_normal()
			if (n.x != 0 && n.y == 0 || n.y == -1 || was_on_floor && n.y <= 0):
				motion = n.slide(motion)
				velocity = n.slide(velocity)
				move(motion)
	
			if (n.y < 0):
				on_floor = true
				velocity.y = 0
				state = "walk"
			if (n.x != 0 && state != "jump"):
				on_floor = false
				velocity.y = -jump
				state = "jump"
				
		if (health <= 0):
			var p = pickup_energy.instance()
			p.set_pos(get_pos())
			get_parent().add_child(p)
			var b = boom.instance()
			b.set_pos(get_pos())
			get_parent().add_child(b)
			queue_free()
