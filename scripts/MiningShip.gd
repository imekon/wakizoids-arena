extends Node2D

const MOVEMENT = 200.0

enum AI_STATUS { IDLE, TURNING, MOVING, TURN_TO_SHOOT, SHOOTING }
enum ROGUE_STATUS { HONEST, ROGUE_HIDDEN, ROGUE }

onready var node2d = $Node2D
onready var registration = $Node2D/Registration
onready var body = $KinematicBody2D
onready var firing_position = $KinematicBody2D/FiringPosition

onready var bullet_resource = load("res://scenes/Bullet.tscn")

var ai_status
var rogue_status
var credits
var shields
var energy
var thrust
var target
var target_position
var target_angle
var target_angle_offset
var target_distance
var last_distance
var last_fired = 0
var firing_count

func _ready():
	ai_status = IDLE
	rogue_status = HONEST
	credits = 0
	shields = 100
	energy = 100
	thrust = 0
	target = null
	var angle = randf() * 360
	last_distance = 0
	body.rotate(deg2rad(angle))
	
func _physics_process(delta):
	#
	# If rogue and cops far away 10000 units attack any mining ships nearby
	#
	# If hidden and cops nearby pick a fight, run or idle
	# If rogue and cops nearby attack
	var miner_position = body.position

	match ai_status:
		IDLE:
			process_idle(delta, miner_position)
		TURNING:
			process_turning(delta, miner_position)
		MOVING:
			process_moving(delta, miner_position)
		TURN_TO_SHOOT:
			process_turn_to_shoot(delta, miner_position)
		SHOOTING:
			process_shooting(delta, miner_position)
	
func process_idle(delta, miner_position):
	var rocks = get_tree().get_nodes_in_group("rocks")
	var closest_rock = null
	var closest_dist = 99999
	var closest_position
	for rock in rocks:
		var pos = rock.position
		var dist = miner_position.distance_to(pos)
		if dist < closest_dist && !rock.is_queued_for_deletion():
			closest_dist = dist
			closest_rock = rock
			closest_position = pos
				
	if closest_rock == null:
		target = null
		return
		
	target = weakref(closest_rock)
	target_position = closest_position
	target_angle = rad2deg(miner_position.angle_to(target_position))
	
	ai_status = TURNING
	
func set_registration(text):
	registration.text = text
	
func process_turning(delta, miner_position):
	var angle = body.rotation_degrees
	var angle_delta
	
	if target_angle> angle:
		angle_delta = 1
	else:
		angle_delta = -1
		
	if abs(angle - target_angle) > 1:
		body.rotate(deg2rad(angle_delta))
	else:
		ai_status = MOVING
		
func process_moving(delta, miner_position):
	if !target.get_ref():
		ai_status = IDLE
		target = null
		
	thrust = MOVEMENT * delta
	var rot = body.rotation_degrees
	var direction = Vector2(thrust, 0).rotated(deg2rad(rot))
	var collide = body.move_and_collide(direction)
	node2d.position = body.position
	
	if target != null && target.get_ref() != null:
		target_position = target.get_ref().position
		target_distance = miner_position.distance_to(target_position)
		if target_distance < 500:
			firing_count = 0
			ai_status = TURN_TO_SHOOT
			
func process_turn_to_shoot(delta, miner_position):
	if !target.get_ref():
		ai_status = IDLE
		target = null

	var pos = target.get_ref().position
	target_angle = rad2deg(miner_position.angle_to(pos))
	
	var angle = body.rotation_degrees
	var angle_delta
	
	if target_angle> angle:
		angle_delta = 1
	else:
		angle_delta = -1
		
	target_angle_offset = abs(angle - target_angle)
		
	if target_angle_offset > 1:
		body.rotate(deg2rad(angle_delta))
	else:
		ai_status = SHOOTING
	
func process_shooting(delta, miner_position):
	var now = OS.get_ticks_msec()
	if now - last_fired > 100:
		var bullet = bullet_resource.instance()
		bullet.position = firing_position.global_position
		bullet.rotate(body.rotation)
		get_parent().add_child(bullet)
		last_fired = now
		firing_count += 1

	if firing_count > 5:
		ai_status = IDLE
		target = null