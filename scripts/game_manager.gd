extends Node

var score = 0
@onready var score_label = $ScoreLabel
@onready var input_label = $WASD/InputLabel
@onready var space = $WASD/Space
@onready var wasd = $WASD/WASD
@onready var x_input = $Xbox/XInput
@onready var a_button = $Xbox/A_Button
@onready var joystick = $Xbox/Joystick

func _process(delta):
	detect_input()

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."

func detect_input():
	var controller_connected = Input.get_connected_joypads().size() > 0
	
	if controller_connected:
		input_label.visible = false
		space.visible = false
		wasd.visible = false
		x_input.visible = true
		a_button.visible = true
		joystick.visible = true
	else:
		input_label.visible = true
		space.visible = true
		wasd.visible = true
		x_input.visible = false
		a_button.visible = false
		joystick.visible = false
