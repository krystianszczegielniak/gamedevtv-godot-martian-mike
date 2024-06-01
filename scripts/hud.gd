extends Control

class_name HUD

func set_time_label(value: int):
	$TimeLabel.text = "TIME: " + str(value)
