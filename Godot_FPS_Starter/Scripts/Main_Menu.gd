extends Control

const START_MENU_BUTTON_START = "start"
const START_MENU_BUTTON_GODOT = "open_godot"
const START_MENU_BUTTON_OPTIONS = "options"
const START_MENU_BUTTON_QUIT = "quit"

const MENU_BUTTON_BACK = "back"

const LEVEL_MENU_BUTTON_TESTING_AREA = "test"
const LEVEL_MENU_BUTTON_RUINS = "ruins"
const LEVEL_MENU_BUTTON_SPACE = "space"

const OPTIONS_MENU_BUTTON_FULLSCREEN = "full"
const OPTIONS_MENU_BUTTON_VSYNC = "vsync"
const OPTIONS_MENU_BUTTON_DEBUG = "debug"

# A variable to hold the Start_Menu Panel.
var start_menu
# A variable to hold the Level_Select_Menu Panel.
var level_select_menu
# A variable to hold the Options_Menu Panel.
var option_menu

# The path to the Testing_Area.tscn file, so we can change to it from this scene.
export (String, FILE) var testing_area_scene
# The path to the Space_Level.tscn file, so we can change to it from this scene.
export (String, FILE) var space_level_scene
# The path to the Ruins_Level.tscn file, so we can change to it from this scene.
export (String, FILE) var ruins_level_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Get all the Panel nodes and assign them to the proper variables.
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu
	option_menu = $Options_Menu
	
	# Connect all the buttons pressed signals to their
	# respective [panel_name_here]_button_pressed functions.
	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", [START_MENU_BUTTON_START])
	$Start_Menu/Button_Open_Godot.connect("pressed", self, "start_menu_button_pressed", [START_MENU_BUTTON_GODOT])
	$Start_Menu/Button_Options.connect("pressed", self, "start_menu_button_pressed", [START_MENU_BUTTON_OPTIONS])
	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", [START_MENU_BUTTON_QUIT])
	
	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_menu_button_pressed", [MENU_BUTTON_BACK])
	$Level_Select_Menu/Button_Level_Ruins.connect("pressed", self, "level_menu_button_pressed", [LEVEL_MENU_BUTTON_RUINS])
	$Level_Select_Menu/Button_Level_Space.connect("pressed", self, "level_menu_button_pressed", [LEVEL_MENU_BUTTON_SPACE])
	$Level_Select_Menu/Button_Level_Testing_Area.connect("pressed", self, "level_menu_button_pressed", [LEVEL_MENU_BUTTON_TESTING_AREA])
	
	$Options_Menu/Button_Back.connect("pressed", self, "option_menu_button_pressed", [MENU_BUTTON_BACK])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "option_menu_button_pressed", [OPTIONS_MENU_BUTTON_FULLSCREEN])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "option_menu_button_pressed", [OPTIONS_MENU_BUTTON_DEBUG])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "option_menu_button_pressed", [OPTIONS_MENU_BUTTON_VSYNC])
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# We get a singleton, called Globals.
	var globals = get_node("/root/Globals")
	$Options_Menu/HSlider_Joypad_Sensitivity.value = globals.joypad_sensitivity
	$Options_Menu/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity

func start_menu_button_pressed(button_name):
	if button_name == START_MENU_BUTTON_START:
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == START_MENU_BUTTON_GODOT:
		OS.shell_open("https://godotengine.org/")
	elif button_name == START_MENU_BUTTON_OPTIONS:
		option_menu.visible = true
		start_menu.visible = false
	elif button_name == START_MENU_BUTTON_QUIT:
		get_tree().quit()

func level_menu_button_pressed(button_name):
	if button_name == MENU_BUTTON_BACK:
		start_menu.visible = true
		level_select_menu.visible = false
	elif button_name == LEVEL_MENU_BUTTON_TESTING_AREA:
		set_mouse_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(testing_area_scene)
	elif button_name == LEVEL_MENU_BUTTON_RUINS:
		set_mouse_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(ruins_level_scene)
	elif button_name == LEVEL_MENU_BUTTON_SPACE:
		set_mouse_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(space_level_scene)

func option_menu_button_pressed(button_name):
	if button_name == MENU_BUTTON_BACK:
		start_menu.visible = true
		option_menu.visible = false
	elif button_name == OPTIONS_MENU_BUTTON_FULLSCREEN:
		OS.window_fullscreen = !OS.window_fullscreen
	elif button_name == OPTIONS_MENU_BUTTON_VSYNC:
		OS.vsync_enabled = $Options_Menu/Check_Button_VSync.pressed
	elif button_name == OPTIONS_MENU_BUTTON_DEBUG:
		get_node("/root/Globals").set_debug_display($Options_Menu/Check_Button_Debug.pressed)

func set_mouse_joypad_sensitivity():
	var globals = get_node("/root/Globals")
	globals.mouse_sensitivity = $Options_Menu/HSlider_Mouse_Sensitivity.value
	globals.joypad_sensitivity = $Options_Menu/HSlider_Joypad_Sensitivity.value

