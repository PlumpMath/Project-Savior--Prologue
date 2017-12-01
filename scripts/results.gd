extends Node2D

var passed = false
var level1 = "res://scenes/level1.tscn"
var level2 = "res://scenes/level2.tscn"
var gameover = "res://scenes/gameover.tscn"
onready var show_timer = get_node("show_timer")
onready var current_label = get_node("current_label")
onready var target_label = get_node("target_label")
onready var badge_enemies = get_node("badge_enemies")
onready var badge_nohit = get_node("badge_nohit")
onready var badge_enemies_label = get_node("badge_enemies_label")
onready var badge_nohit_label = get_node("badge_nohit_label")
onready var pass_label = get_node("pass_label")
onready var command_label = get_node("command_label")

func _ready():
	if (!global.b_enemies || !global.b_nohit):
		global.perfect = false
	elif (global.level == 1 && global.b_enemies && global.b_nohit):
		global.perfect = true
	show_timer.set_wait_time(10)
	show_timer.start()
	var minutes = global.time / 60
	var seconds = global.time % 60
	var tmins
	var tsecs
	if (global.level == 1):
		tmins = 2
		tsecs = 0
	else:
		tmins = 5
		tsecs = 0
	if (minutes < tmins || (minutes == tmins && seconds <= tsecs)):
		passed = true
	current_label.set_text("current time :              %02d : %02d" % [minutes, seconds])
	current_label.hide()
	target_label.set_text("target time :                %02d : %02d" % [tmins, tsecs])
	target_label.hide()
	badge_enemies.hide()
	badge_nohit.hide()
	badge_enemies_label.hide()
	badge_nohit_label.hide()
	if (!global.b_enemies):
		badge_enemies_label.set_opacity(0.5)
	if (!global.b_nohit):
		badge_nohit_label.set_opacity(0.5)
	if (passed):
		pass_label.set_text("Crisis aversion possible.")
		if (global.perfect):
			pass_label.add_color_override("font_color", Color(1, 0, 0))
		command_label.set_text("Press Z to continue")
	else:
		pass_label.set_text("Too late.")
		command_label.set_text("Press Z to retry")
	pass_label.hide()
	command_label.hide()
	set_process(true)
	
func _process(delta):
	if (!current_label.is_visible() && show_timer.get_time_left() < 8):
		current_label.show()
	if (!target_label.is_visible() && show_timer.get_time_left() < 6):
		target_label.show()
	if (!pass_label.is_visible() && show_timer.get_time_left() < 4):
		badge_enemies.show()
		badge_nohit.show()
		badge_enemies_label.show()
		badge_nohit_label.show()
	if (!pass_label.is_visible() && show_timer.get_time_left() < 2):
		pass_label.show()
	if (show_timer.get_time_left() <= 1):
		show_timer.stop()
		if (!command_label.is_visible()):
			command_label.show()
		if (Input.is_action_pressed("results")):
			if (passed):
				global.level += 1
				if (global.level == 2):
					get_tree().change_scene(level2)
				elif (global.level == 3):
					get_tree().change_scene(gameover)
			else:
				global.level = 1
				global.time = 0
				get_tree().change_scene(level1)