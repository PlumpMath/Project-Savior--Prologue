extends KinematicBody2D

# class member variables go here, for example:
const SHOOT_TIME = 800
var velocity = Vector2()
var shoot_timer = (SHOOT_TIME / 2)
var health = 160
var state = "idle"
var bot = preload("res://scenes/bot.tscn")
var boom = preload("res://scenes/boom.tscn")
onready var player = get_node("../../player")
onready var boss_flower = get_node("../boss_flower")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
	
func _ready():
	if (global.hard_mode):
		health = 200
	add_to_group("enemies")
	anim.play("idle")
	anim.set_speed(1)
	anim.seek(randf() / 2)
	set_fixed_process(true)
	
func _fixed_process(delta):
	if (velocity != Vector2(0, 0)):
		state = "hurt"
		anim.play("hurt")
		anim.seek(0)
		velocity = Vector2(0, 0)
	if (state == "idle"):
		if (shoot_timer <= 0):
			var b = bot.instance()
			var shoot_pos = Vector2(get_pos().x - 20, get_pos().y)
			if (get_pos().x > boss_flower.get_pos().x - 10):
				shoot_pos = Vector2(get_pos().x + 20, get_pos().y)
			b.velocity = Vector2(-100, -200)
			b.set_pos(shoot_pos)
			get_parent().add_child(b)
			b = boom.instance()
			b.set_pos(shoot_pos)
			get_parent().add_child(b)
			shoot_timer = SHOOT_TIME
		else:
			shoot_timer -= 1
	
	if (health <= 0):
		var b = boom.instance()
		b.set_pos(get_pos())
		get_parent().add_child(b)
		queue_free()


func _on_AnimationPlayer_finished():
	if (anim.get_current_animation() == "hurt"):
		state = "idle"
		anim.play("idle")
		anim.seek(0)
