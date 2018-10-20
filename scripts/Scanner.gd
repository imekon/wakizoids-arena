extends Node2D

onready var scanner = $PanelContainer/Panel/ScannerControl

func set_short_range_scanner():
	scanner.set_short_range_scan()
	
func set_medium_range_scanner():
	scanner.set_medium_range_scan()
	
func set_long_range_scanner():
	scanner.set_long_range_scan()
	