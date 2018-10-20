extends Panel

onready var label = $RichTextLabel

var ship

func _ready():
	ship = null

func on_timer_tick():
	if ship == null:
		return
		
	label.clear()
		
	match ship.ai_status:
		0:
			label.add_text("Status: IDLE\n")
		1:
			label.add_text("Status: TURNING\n")
		2:
			label.add_text("Status: MOVING\n")
		3:
			label.add_text("Status: TURN_TO_SHOOT\n")
		4:
			label.add_text("Status: SHOOTING\n")
			
	label.add_text("Target: " + str(ship.target) + "\n")
	label.add_text("Target distance: " + str(ship.target_distance) + "\n")
	label.add_text("Target angle: " + str(ship.target_angle) + "\n")
	label.add_text("Target Angle Offset: " + str(ship.target_angle_offset))
