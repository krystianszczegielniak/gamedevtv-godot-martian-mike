extends Node2D

@export var next_level: PackedScene
@export var level_time: int = 5
@export var is_final_level: bool = false

@onready var start = $Start
@onready var player = $Player
@onready var exit = $Exit
@onready var death_zone = $Deathzone
@onready var hud: HUD = $UILayer/HUD
@onready var ui_layer = $UILayer

var timer_node: Timer = null

var time_left: int

var win = false

func _ready():
	player.global_position = start.get_spawn_position()
	var traps = get_tree().get_nodes_in_group("traps")
	for trap in traps:
		#trap.connect("touched_player", _on_trap_touched_player)
		trap.touched_player.connect(_on_trap_touched_player)
	
	death_zone.body_entered.connect(_on_deathzone_body_entered)
	
	exit.body_entered.connect(_on_exit_body_entered)
	
	time_left = level_time
	hud.set_time_label(time_left)
	timer_node = _create_timer()
	add_child(timer_node)

func _create_timer():
	var tn = Timer.new()
	tn.name = "Level Timer"
	tn.wait_time = 1
	tn.autostart = true
	tn.timeout.connect(_on_level_timer_timeout)
	return tn
	
func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_deathzone_body_entered(_body: Node2D):
	AudioPlayer.play_sfx("hurt")
	reset_player()

func reset_player():
	player.velocity = Vector2.ZERO
	player.global_position = start.get_spawn_position()

func _on_trap_touched_player():
	AudioPlayer.play_sfx("hurt")
	reset_player()
	
func _on_exit_body_entered(body):
	if body is Player:
		if is_final_level or (next_level != null):
			exit.animate()
			player.active = false
			win = true
			await get_tree().create_timer(2).timeout
			if is_final_level:
				ui_layer.show_win_screen(true)
			else:
				get_tree().change_scene_to_packed(next_level)

func _on_level_timer_timeout():
	if not win:
		time_left -= 1
		hud.set_time_label(time_left)
		if time_left < 0:
			reset_player()
			time_left = level_time
			hud.set_time_label(time_left)
