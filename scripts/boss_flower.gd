extends KinematicBody2D

# class member variables go here, for example:
var velocity = Vector2()
var plantarr = []
var shoot_timer = 0
var max_health = 1200.0
var refill = 0
var health = max_health
var state = "sprout"
var bar
var song = load("sounds/boss.ogg")
var bossbar = preload("res://scenes/bossbar.tscn")
var shooter = preload("res://scenes/boss_flower_shooter.tscn")
var generator = preload("res://scenes/boss_flower_generator.tscn")
var boom = preload("res://scenes/boom.tscn")
var refill_bar = true
onready var player = get_node("../../player")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
onready var mask = get_node("CollisionShape2D")
onready var music = get_node("../../StreamPlayer")
onready var camera = get_node("../../player/camera")
	
func _ready():
	if (global.hard_mode):
		max_health = 2000.0
		health = max_health
	add_to_group("enemies")
	anim.play("sprout")
	anim.set_speed(0)
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (state == "sprout"):
		var dist_pos = Vector2(get_pos().x, get_pos().y + 150)
		if (abs(dist_pos.x - player.get_pos().x) < 128):
			anim.set_speed(1.5)
	else:
		if (refill_bar):
			refill += (max_health - refill) / 8
			bar.set_scale(Vector2((refill / max_health) * 464, 1))
			if (refill >= health):
				refill_bar = false
		else:
			bar.set_scale(Vector2((health / max_health) * 464, 1))
		if (state == "idle"):
			if (anim.get_current_animation() != "idle"):
				anim.seek(0)
				anim.play("idle")
		if (health <= 0):
			var b = boom.instance()
			b.set_pos(get_pos())
			get_parent().add_child(b)
			while (plantarr.size() > 0):
				var wr = weakref(plantarr[0])
				if (wr.get_ref()):
					plantarr[0].queue_free()
				plantarr.pop_front()
			player.set_right_limit(6000)
			player.next_limit = 4200
			music.stop()
			queue_free()

func create_shooter(x, y):
	var s = shooter.instance()
	s.set_pos(Vector2(get_pos().x + x, get_pos().y + y))
	get_parent().add_child(s)
	plantarr.push_back(s)
	var b = boom.instance()
	b.set_pos(Vector2(get_pos().x + x, get_pos().y + y))
	get_parent().add_child(b)
	
func create_generator(x, y):
	var g = generator.instance()
	g.set_pos(Vector2(get_pos().x + x, get_pos().y + y))
	get_parent().add_child(g)
	plantarr.push_back(g)
	var b = boom.instance()
	b.set_pos(Vector2(get_pos().x + x, get_pos().y + y))
	get_parent().add_child(b)

func _on_AnimationPlayer_finished():
	if (anim.get_current_animation() == "sprout"):
		state = "idle"
		create_shooter(-30, 15)
		create_generator(0, 60)
		create_generator(-60, 100)
		create_shooter(35, 140)
		anim.set_speed(1)
		player.set_left_limit(3450)
		set_layer_mask_bit(1, true)
		set_collision_mask_bit(1, true)
		bar = bossbar.instance()
		bar.set_pos(Vector2(8, 304))
		get_node("../../CanvasLayer").add_child(bar)
		music.set_stream(song)
		music.play()
