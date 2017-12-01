extends KinematicBody2D

# class member variables go here, for example:
var velocity = Vector2()
var tvelocity = Vector2()
var target_pos = Vector2()
var shoot_timer = 0
var c_max_action_timer = 300
var max_action_timer = c_max_action_timer
var action_timer = max_action_timer
var max_health = 800.0
var refill = 0
var health = max_health
var state = "sleep"
var lefthand
var righthand
var lhwr
var rhwr
var bar
var song = load("sounds/boss2.ogg")
var bossbar = preload("res://scenes/bossbar.tscn")
var hand = preload("res://scenes/boss_mech_hand.tscn")
var boom = preload("res://scenes/boom.tscn")
var refill_bar = true
var instance = false
var up = false
onready var player = get_node("../../player")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
onready var mask = get_node("CollisionShape2D")
onready var music = get_node("../../StreamPlayer")
onready var camera = get_node("../../player/camera")
	
func _ready():
	if (global.hard_mode):
		c_max_action_timer = 240
		max_health = 1200.0
		health = max_health
	add_to_group("enemies")
	anim.play("idle")
	target_pos = get_pos()
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (instance):
		instance = false
		lefthand = hand.instance()
		lefthand.set_pos(Vector2(get_pos().x - 50, get_pos().y - 800))
		get_parent().add_child(lefthand)
		righthand = hand.instance()
		righthand.set_pos(Vector2(get_pos().x + 50, get_pos().y - 800))
		righthand.right = true
		get_parent().add_child(righthand)
		lhwr = weakref(lefthand)
		rhwr = weakref(righthand)
		
	if (state == "sleep"):
		var dist_pos = Vector2(get_pos().x, get_pos().y + 150)
		if (abs(dist_pos.x - player.get_pos().x) < 192):
			instance = true
			state = "idle"
			player.set_left_limit(2900)
			player.set_right_limit(3550)
			bar = bossbar.instance()
			bar.set_pos(Vector2(8, 304))
			set_layer_mask_bit(1, true)
			set_collision_mask_bit(1, true)
			get_node("../../CanvasLayer").add_child(bar)
			music.set_stream(song)
			music.play()
	else:
		if (refill_bar):
			refill += (max_health - refill) / 8
			bar.set_scale(Vector2((refill / max_health) * 464, 1))
			if (refill >= health):
				refill_bar = false
		else:
			bar.set_scale(Vector2((health / max_health) * 464, 1))
		if (state == "idle"):
			max_action_timer = (c_max_action_timer - 60) + (refill / max_health) * 60
			if (anim.get_current_animation() != "idle"):
				anim.seek(0)
				anim.play("idle")
			if (up):
				tvelocity.y += 1
				if (tvelocity.y > 20):
					up = false
			else:
				tvelocity.y -= 1
				if (tvelocity.y < -20):
					up = true
			set_pos(Vector2(get_pos().x + (target_pos.x - get_pos().x) / 16, get_pos().y + (target_pos.y - get_pos().y) / 16))
			action_timer -= 1
			if (action_timer <= 0):
				state = "shoot"
				if (lhwr.get_ref()):
					var rand = randi() % 3
					if (rand == 0):
						lefthand.state = "shoot"
						lefthand.target_pos = Vector2(get_pos().x - 100, get_pos().y)
					elif (rand == 1):
						lefthand.state = "summon"
						lefthand.target_pos = Vector2(get_pos().x - 100, get_pos().y - 100)
					else:
						lefthand.state = "bomb"
						lefthand.target_pos = Vector2(get_pos().x - 100, get_pos().y - 50)
				if (rhwr.get_ref()):
					var rand = randi() % 3
					if (rand == 0):
						righthand.state = "shoot"
						righthand.target_pos = Vector2(get_pos().x + 100, get_pos().y)
					elif (rand == 1 && lefthand.state != "summon"):
						righthand.state = "summon"
						righthand.target_pos = Vector2(get_pos().x + 100, get_pos().y - 100)
					else:
						righthand.state = "bomb"
						righthand.target_pos = Vector2(get_pos().x + 100, get_pos().y - 50)
				action_timer = max_action_timer
		elif (state == "shoot"):
			action_timer -= 1
			if (action_timer <= 0):
				state = "idle"
				var rand = randi() % 6
				if (rand == 0):
					target_pos = Vector2(3420, -2105)
				elif (rand == 1):
					target_pos = Vector2(3240, -2105)
				elif (rand == 2):
					target_pos = Vector2(3000, -2105)
				elif (rand == 0):
					target_pos = Vector2(3420, -2205)
				elif (rand == 1):
					target_pos = Vector2(3240, -2205)
				else:
					target_pos = Vector2(3000, -2205)
				if (lhwr.get_ref()):
					lefthand.state = "idle"
					lefthand.target_pos = Vector2(target_pos.x - 50, target_pos.y)
				if (rhwr.get_ref()):
					righthand.state = "idle"
					righthand.target_pos = Vector2(target_pos.x + 50, target_pos.y)
				action_timer = max_action_timer
		if (health <= 0):
			var b = boom.instance()
			b.set_pos(get_pos())
			get_parent().add_child(b)
			player.set_right_limit(6000)
			player.next_limit = 3750
			if (lhwr.get_ref()):
				lefthand.queue_free()
			if (rhwr.get_ref()):
				righthand.queue_free()
			music.stop()
			queue_free()
			
	var motion = tvelocity * delta
	move(motion)

func _on_AnimationPlayer_finished():
	pass
