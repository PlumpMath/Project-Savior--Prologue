extends KinematicBody2D

# class member variables go here, for example:
var move_speed = 100
var max_speed = 50
var max_y_speed = 2000
var add_speed = 50
var ship_speed = 300
var max_ship_speed = 300
var jump = 400
var gravity = 30
var max_gravity = 400
var stop_factor = 0.1
var stop_threshold = 2
var shoot_timer = 0
var left_limit = 0
var right_limit = 0
var next_limit = -1
var max_energy = 500.0
var energy_regen = 0.2
var energy = max_energy
var velocity = Vector2()
var on_floor = false
var jumped = false
var shooting = false
var ship_mode = false
var resolve_collision = false
var bullet = preload("res://scenes/bullet.tscn")
var boom = preload("res://scenes/boom.tscn")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
onready var camera = get_node("camera")
onready var hitbox = get_node("hitbox")
onready var energybar = get_node("../CanvasLayer/energybar")
onready var screen_cover = get_node("../CanvasLayer/screen_cover")
onready var audio = get_node("../SamplePlayer")
	
func _ready():
	if (global.hard_mode):
		max_energy = 400.0
	global.b_nohit = true
	global.b_enemies = false
	add_to_group("player")
	set_fixed_process(true)
	set_process_input(true)
	set_right_limit(4050)
	if (get_tree().get_current_scene().get_name() == "level2"):
		camera.set_limit(MARGIN_TOP, -8000)
	
func switch_hitbox_ship():
	hitbox.set_pos(Vector2(hitbox.get_pos().x, 0.42705))
	hitbox.set_scale(Vector2(hitbox.get_scale().x, 0.350056))
	
func switch_hitbox_player():
	hitbox.set_pos(Vector2(hitbox.get_pos().x, 6.48491))
	hitbox.set_scale(Vector2(hitbox.get_scale().x, 0.956459))

func set_left_limit(limit):
	camera.set_limit(MARGIN_LEFT, limit)
	left_limit = limit
	
func set_right_limit(limit):
	camera.set_limit(MARGIN_RIGHT, limit)
	right_limit = limit
	
func create_boom():
	var b = boom.instance()
	get_parent().add_child(b)
	b.set_pos(get_pos())
	b.set_speed(3)
	
func switch_to_player_mode():
	ship_mode = false
	shooting = false
	switch_hitbox_player()
	resolve_collision = true
	create_boom()

func _input(event):
	if (event.is_action_pressed("jump") && energy > 0 && jumped && !ship_mode):
		ship_mode = true
		switch_hitbox_ship()
		create_boom()
	if (event.is_action_released("jump") && ship_mode):
		switch_to_player_mode()
	
func _fixed_process(delta):
	if (get_tree().get_nodes_in_group("enemies").size() <= 0):
		global.b_enemies = true
	
	var speed = move_speed
	if (ship_mode):
		energy -= 1
		if (energy <= 0):
			switch_to_player_mode()
		speed = ship_speed
		if (Input.is_action_pressed("move_up")):
			velocity.y -= speed
		if (Input.is_action_pressed("move_down")):
			velocity.y += speed
		if (!Input.is_action_pressed("move_up") && !Input.is_action_pressed("move_down")):
			velocity.y *= stop_factor
			if (velocity.y < stop_threshold && velocity.y > -stop_threshold):
				velocity.y = 0
	elif (energy < max_energy):
		energy += energy_regen
	if (energy > max_energy):
		energy = max_energy
	elif (energy < 0):
		energy = 0
	if (Input.is_action_pressed("move_left")):
		velocity.x -= speed
		if (!ship_mode):
			sprite.set_flip_h(true)
	if (Input.is_action_pressed("move_right")):
		velocity.x += speed
		if (!ship_mode):
			sprite.set_flip_h(false)
	if (!Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right")):
		velocity.x *= stop_factor
		if (velocity.x < stop_threshold && velocity.x > -stop_threshold):
			velocity.x = 0
			
	if (on_floor || ship_mode):
		if (Input.is_action_pressed("shoot")):
			if (!ship_mode):
				velocity.x = 0
			shooting = true
			if (shoot_timer <= 0):
				var b = bullet.instance()
				var xoffset = 16
				var yoffset = 7
				if (ship_mode):
					xoffset = 20
					yoffset = 4
				b.velocity.x = 10
				if (sprite.is_flipped_h()):
					xoffset *= -1
					b.velocity.x *= -1
				b.set_pos(Vector2(get_pos().x + xoffset, get_pos().y + yoffset + randi() % 5 - 2))
				b.add_to_group("bullets")
				get_parent().add_child(b)
				audio.play("shoot")
				shoot_timer = 5 - 4 * (energy / max_energy)
			else:
				shoot_timer -= 1
		else:
			shooting = false
			if (!ship_mode && Input.is_action_pressed("jump")):
				velocity.y = -jump
				on_floor = false
				jumped = true
	
		
	if (ship_mode):
		if (shooting && anim.get_current_animation() != "ship_shoot"):
			anim.set_speed(1)
			anim.seek(0)
			anim.play("ship_shoot")
		elif (!shooting && anim.get_current_animation() != "ship"):
			anim.set_speed(1)
			anim.seek(0)
			anim.play("ship")
	elif (shooting):
		if (anim.get_current_animation() != "shoot"):
			anim.set_speed(15)
			anim.seek(0)
			anim.play("shoot")
	elif (!on_floor && abs(velocity.y) > 100 || jumped):
		if (anim.get_current_animation() != "jump"):
			anim.set_speed(6)
			anim.seek(0)
			anim.play("jump")
		else:
			if (velocity.y < 0 && anim.get_pos() > 1.5):
				anim.seek(0, true)
			elif (velocity.y >= 0):
				anim.seek(1.5, true)
	elif (velocity.x != 0):
		if (anim.get_current_animation() != "run"):
			anim.set_speed(7)
			anim.seek(0)
			anim.play("run")
	elif (anim.get_current_animation() != "idle"):
		anim.set_speed(1)
		anim.seek(0)
		anim.play("idle")
		
	if (ship_mode):
		if (velocity.x > max_ship_speed):
			velocity.x = max_ship_speed
		elif (velocity.x < -max_ship_speed):
			velocity.x = -max_ship_speed
		if (velocity.y > max_ship_speed):
			velocity.y = max_ship_speed
		elif (velocity.y < -max_ship_speed):
			velocity.y = -max_ship_speed
	else:
		if (velocity.x > max_speed + add_speed * (energy / max_energy)):
			velocity.x = max_speed + add_speed * (energy / max_energy)
		elif (velocity.x < -max_speed - add_speed * (energy / max_energy)):
			velocity.x = -max_speed - add_speed * (energy / max_energy)
	
		if (!on_floor):
			velocity.y += gravity
		if (velocity.y > max_gravity):
			velocity.y = max_gravity
		if (velocity.y < -max_gravity):
			velocity.y = -max_gravity
	
	var motion = velocity * delta
	move(motion)
	
	var was_on_floor = on_floor
	on_floor = false
	if (is_colliding()):
		var n = get_collision_normal()
			
		if (n.x != 0 && n.y == 0 || n.y == -1 || n.y == 1 || was_on_floor && n.y <= 0 || resolve_collision):
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
			
		if (is_colliding() && resolve_collision):
			set_pos(Vector2(get_pos().x + n.x, get_pos().y - 1))

		if (n.y < 0 && !ship_mode):
			on_floor = true
			jumped = false
			velocity.y = 0
	else:
		resolve_collision = false
		
	if (get_pos().x < left_limit):
		set_pos(Vector2(left_limit, get_pos().y))
		velocity.x = 0
	if (get_pos().x > right_limit):
		set_pos(Vector2(right_limit, get_pos().y))
		velocity.x = 0
	if (next_limit > 0 && get_pos().x > next_limit):
		screen_cover.exit = true

	energybar.set_region_rect(Rect2(0, 0, energybar.get_texture().get_width() * (energy / max_energy), energybar.get_texture().get_height()))
