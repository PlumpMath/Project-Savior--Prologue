extends KinematicBody2D

# class member variables go here, for example:
const NONE_THRESHOLD = 480
const ATTACK_TIME = 40
var gravity = 3
var max_gravity = 200
var attack_timer = 0
var max_health = 80
var bullets = 0
var health = max_health
var velocity = Vector2()
var on_floor = false
var first = true
var state = "idle"
var bullet = preload("res://scenes/bullet_turret.tscn")
var bullet_large = preload("res://scenes/bullet_turret_large.tscn")
var pickup_energy = preload("res://scenes/pickup_energy.tscn")
var boom = preload("res://scenes/boom.tscn")
onready var player = get_node("../../player")
onready var sprite = get_node("Sprite")
onready var anim = get_node("AnimationPlayer")
	
func _ready():
	add_to_group("enemies")
	set_fixed_process(true)
	
func create_bullet(bvel):
	var b = bullet.instance()
	var shoot_pos = Vector2(get_pos().x, get_pos().y)
	b.velocity = bvel
	b.damage = 20
	b.set_pos(shoot_pos)
	get_parent().add_child(b)
	
func create_bullet_large(bvel):
	var b = bullet_large.instance()
	var shoot_pos = Vector2(get_pos().x, get_pos().y)
	b.velocity = bvel
	b.damage = 120
	b.set_pos(shoot_pos)
	get_parent().add_child(b)
	
func _fixed_process(delta):
	velocity.x = 0
	
	if (bullets > 0):
		bullets -= 1
		if (bullets % 5 == 0):
			create_bullet((player.get_pos() - get_pos()).normalized() * 2)
	
	if (state == "idle"):
		if (attack_timer <= 0 && get_pos().y > player.get_pos().y && get_pos().distance_to(player.get_pos()) < NONE_THRESHOLD):
			if (first):
				state = "attack"
				bullets = 25
			else:
				state = "attack2"
				create_bullet_large((player.get_pos() - get_pos()).normalized())
			attack_timer = ATTACK_TIME
			first = !first
		else:
			attack_timer -= 1
		
	if (state == "idle" && anim.get_current_animation() != "idle"):
		anim.seek(0)
		anim.play("idle")
	elif (state == "attack" && anim.get_current_animation() != "attack"):
		anim.seek(0)
		anim.play("attack")
	elif (state == "attack2" && anim.get_current_animation() != "attack2"):
		anim.seek(0)
		anim.play("attack2")
	
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


func _on_AnimationPlayer_finished():
	if (anim.get_current_animation() == "attack" || anim.get_current_animation() == "attack2"):
		state = "idle"
