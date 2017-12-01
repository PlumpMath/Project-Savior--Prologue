extends KinematicBody2D

# class member variables go here, for example:
const NONE_THRESHOLD = 480
const ATTACK_TIME = 120
const IDLE_ATTACK_TIME = 10
var move_speed = 150
var max_speed = 150
var jump = 200
var gravity = 3
var max_gravity = 200
var stop_factor = 0.1
var stop_threshold = 2
var attack_timer = 0
var max_health = 40
var health = max_health
var velocity = Vector2()
var on_floor = false
var jumped = false
var shot = false
var state = "idle"
var bullet = preload("res://scenes/bullet_rose.tscn")
var pickup_energy = preload("res://scenes/pickup_energy.tscn")
var boom = preload("res://scenes/boom.tscn")
onready var player = get_node("../../player")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
	
func _ready():
	if (global.hard_mode):
		var max_health = 50
		var health = max_health
	add_to_group("enemies")
	set_fixed_process(true)
	
func create_bullet(bvel):
	var b = bullet.instance()
	var shoot_pos = Vector2(get_pos().x, get_pos().y - 10)
	b.velocity = bvel
	b.set_pos(shoot_pos)
	get_parent().add_child(b)
	
func _fixed_process(delta):
	if (state == "idle"):
		velocity.x *= stop_factor
		if (velocity.x < stop_threshold && velocity.x > -stop_threshold):
			velocity.x = 0
		if (attack_timer <= 0):
			create_bullet(Vector2(0, -300))
			attack_timer = IDLE_ATTACK_TIME
		else:
			attack_timer -= 1
			
	if (on_floor):
		if (state == "idle" && get_pos().distance_to(player.get_pos()) < NONE_THRESHOLD):
			if (attack_timer <= 0 && health < max_health):
				state = "jump"
				if (get_pos().x > player.get_pos().x):
					velocity.x = -move_speed
				else:
					velocity.x = move_speed
				velocity.y = -jump
				on_floor = false
				shot = false
			else:
				attack_timer -= 1
		elif (state == "jump"):
			state = "idle"
			attack_timer = ATTACK_TIME
			velocity.x = 0
			
	if (state == "jump" && !shot && anim.get_current_animation_pos() >= 1):
		create_bullet(Vector2(-300, -100))
		create_bullet(Vector2(-100, -150))
		create_bullet(Vector2(300, -100))
		create_bullet(Vector2(100, -150))
		create_bullet(Vector2(-400, -110))
		create_bullet(Vector2(-200, -160))
		create_bullet(Vector2(400, -110))
		create_bullet(Vector2(200, -160))
		shot = true
		
	if (state == "jump" && anim.get_current_animation() != "attack"):
		anim.seek(0)
		anim.play("attack")
	elif (state == "idle" && anim.get_current_animation() != "idle"):
		anim.seek(0)
		anim.play("idle")
		
	if (velocity.x > max_speed):
		velocity.x = max_speed
	elif (velocity.x < -max_speed):
		velocity.x = -max_speed
	
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
			
	if (health <= 0):
		var p = pickup_energy.instance()
		p.set_pos(get_pos())
		get_parent().add_child(p)
		var b = boom.instance()
		b.set_pos(get_pos())
		get_parent().add_child(b)
		queue_free()
		