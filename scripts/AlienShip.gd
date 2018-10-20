extends KinematicBody2D

const MOVEMENT = 100.0

var thrust

func _ready():
	var angle = randf() * 360
	rotate(deg2rad(angle))

func _physics_process(delta):
	thrust = MOVEMENT * delta
	var rot = rotation_degrees - 90
	var direction = Vector2(thrust, 0).rotated(deg2rad(rot))
	var collide = move_and_collide(direction)

