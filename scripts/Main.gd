extends Node2D

onready var ship = $MiningShip
onready var camera = $MiningShip/Camera2D
onready var status = $CanvasLayer/MinerStatus

func _ready():
	status.ship = ship

func _physics_process(delta):
	camera.position = ship.body.global_position