extends KinematicBody2D

# class member variables go here, for example:
const SHOOT_TIME = 2
const MAX_BULLETS = 8
var target_pos = Vector2()
var velocity = Vector2()
var tvelocity = Vector2()
var shoot_timer = 0
var health = 400
var fall_amount = 800
var bullets = 0
var state = "falling"
var up = false
var right = false
var summoned = false
var bullet = preload("res://scenes/bullet_mech.tscn")
var bomb = preload("res://scenes/bomb.tscn")
var rose = preload("res://scenes/rose.tscn")
var boom = preload("res://scenes/boom.tscn")
onready var player = get_node("../../player")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
	
func _ready():
	if (global.hard_mode):
		health = 500
	add_to_group("enemies")
	anim.play("idle")
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (right):
		set_scale(Vector2(-1, 1))
		
	if (state == "falling"):
		set_pos(Vector2(get_pos().x, get_pos().y + fall_amount / 8))
		fall_amount -= fall_amount / 8
		if (fall_amount < 8):
			state = "idle"
			target_pos = get_pos()
	else:
		if (get_pos().distance_to(target_pos) > 16):
				set_pos(Vector2(get_pos().x + (target_pos.x - get_pos().x) / 16, get_pos().y + (target_pos.y - get_pos().y) / 16))
		if (state == "idle"):
			bullets = MAX_BULLETS
			summoned = false
			if (up):
				tvelocity.y += 0.5
				if (tvelocity.y > 10):
					up = false
			else:
				tvelocity.y -= 0.5
				if (tvelocity.y < -10):
					up = true
			set_rotd(get_rotd() / 2)
			if (anim.get_current_animation() != "idle"):
				anim.seek(0)
				anim.play("idle")
		elif (state == "shoot"):
			if (get_pos().distance_to(target_pos) <= 16):
				if (anim.get_current_animation() != "shoot"):
					anim.seek(0)
					anim.play("shoot")
				if (anim.get_pos() >= 0.5 && anim.get_pos() < 1):
					if (right):
						set_rotd(get_rotd() + 1)
					else:
						set_rotd(get_rotd() - 1)
				if (shoot_timer <= 0 && bullets > 0 && anim.get_pos() >= 0.5):
					var b = bullet.instance()
					var offset = -0.2
					if (bullets > 4 && bullets < 7):
						offset = -0.1
					elif (bullets > 2 && bullets < 5):
						offset = 0.1
					elif (bullets < 3):
						offset = 0.2
					var create_offset = Vector2(cos(get_rot() - offset), -sin(get_rot() - offset)) * 60
					if (right):
						b.velocity = Vector2(-cos(get_rot()), sin(get_rot())) * 20
						create_offset = Vector2(-cos(get_rot() + offset), sin(get_rot() + offset)) * 60
					else:
						b.velocity = Vector2(cos(get_rot()), -sin(get_rot())) * 20
					b.set_pos(get_pos() + create_offset)
					get_parent().add_child(b)
					shoot_timer = SHOOT_TIME
					bullets -= 1
				else:
					shoot_timer -= 1
		elif (state == "summon" || state == "bomb"):
			if (right && get_rotd() < 90):
				set_rotd(get_rotd() + 3)
			elif (!right && get_rotd() > -90):
				set_rotd(get_rotd() - 3)
			if (get_pos().distance_to(target_pos) <= 16):
				if (anim.get_current_animation() != "open"):
					anim.seek(0)
					anim.play("open")
				if (!summoned && anim.get_pos() >= 0.5):
					if (state == "summon"):
						var r = rose.instance();
						r.set_pos(Vector2(get_pos().x, get_pos().y + 16))
						get_parent().add_child(r)
					else:
						var b = bomb.instance();
						b.set_pos(Vector2(get_pos().x, get_pos().y + 16))
						get_parent().add_child(b)
					summoned = true
				
	
	if (health <= 0):
		var b = boom.instance()
		b.set_pos(get_pos())
		get_parent().add_child(b)
		queue_free()
		
	var motion = tvelocity * delta
	move(motion)

func _on_AnimationPlayer_finished():
	if (anim.get_current_animation() == "open"):
		state = "idle"
		anim.play("idle")
		anim.seek(0)
