extends KinematicBody2D

const MOVEMENT = 700.0

var thrust = 0.0
var score
var energy
var shields
var last_fired = 0

onready var firing_position = $FiringPosition

onready var bullet_resource = load("res://scenes/Bullet.tscn")

func _ready():
	score = 0
	energy = 500
	shields = 200

func _physics_process(delta):
	var angle = 0.0

	if Input.is_action_pressed("ui_forwards"):
		thrust = MOVEMENT * delta
	if Input.is_action_pressed("ui_backwards"):
		thrust = -MOVEMENT * delta * 0.25
	if Input.is_action_pressed("ui_left"):
		angle = -2
	if Input.is_action_pressed("ui_right"):
		angle = 2
		
	if Input.is_action_pressed("ui_fire"):
		fire()
	
	# -90 because the graphic is already rotated
	var rot = rotation_degrees - 90

	# leave this here as the non godot way to do movement
	#var x = cos(deg2rad(-rot)) * thrust
	#var y = -sin(deg2rad(-rot)) * thrust
	#var direction = Vector2(x, y)
	var direction = Vector2(thrust, 0).rotated(deg2rad(rot))

	var collide = move_and_collide(direction)
	if collide != null:
		process_collision(collide)
		
	rotate(deg2rad(angle))
	
	thrust *= 0.9
	
func fire():
	var now = OS.get_ticks_msec()
	if now - last_fired > 100:
		var bullet = bullet_resource.instance()
		bullet.player_owned = true
		bullet.position = firing_position.global_position
		bullet.rotate(rotation)
		get_parent().add_child(bullet)
		last_fired = now
	
func process_collision(collision):
	print("you hit something")
	