extends Node

# When adding nodes to a singleton/autoload, you have to be careful
# not to lose reference to any of the child nodes.
# This is because nodes will not be freed/destroyed when you change
# the active scene, meaning you can run into memory problems if you are
# instancing/spawning lots of nodes and you are not freeing them.

# The current sensitivity for our mouse, so we can load it in Player.gd.
var mouse_sensitivity = 0.1
# The current sensitivity for our joypad, so we can load it in Player.gd.
var joypad_sensitivity = 2

# ------------------------------------------
# ---- All the GUI/UI-related variables ----
# A canvas layer so the GUI/UI created in Globals.gd is always drawn on top.
var canvas_layer = null

# The debug display scene.
const DEBUG_DISPLAY_SCENE = preload("res://Debug_Display.tscn")
# A variable to hold the debug display when/if there is one.
var debug_display = null
# ------------------------------------------

# ------------------------------------------
# ------ Pause Popup related variables -----
# The path to the main menu scene.
const MAIN_MENU_PATH = "res://Main_Menu.tscn"
# The pop up scene we looked at earlier.
const POPUP_SCENE = preload("res://Pause_Popup.tscn")
# A variable to hold the pop up scene.
var popup = null
# ------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Because Globals.gd is an autoload/singleton,
	# Godot will make a Node when the game is launched,
	# and it will have Globals.gd attached to it.
	# Since Godot makes a Node, we can treat Globals.gd like any other
	#node with regard to adding/removing children nodes.
	
	# Create a new canvas layer, assign it to canvas_layer.
	canvas_layer = CanvasLayer.new()
	# Add it as a child.
	add_child(canvas_layer)

func _process(delta):
	print("Inside _process")
	if Input.is_action_just_pressed("ui_cancel"):
		if popup != null:
			print("Popup exist's")
			get_tree().paused = false
			popup.queue_free()
			popup = null
		print("ESC just pressed")
		if popup == null:
			print("Popup does not exist's")
			popup = POPUP_SCENE.instance()
			
			popup.get_node("Button_quit").connect("pressed", self, "popup_quit")
			popup.connect("popup_hide", self, "popup_closed")
			popup.get_node("Button_resume").connect("pressed", self, "popup_closed")
			
			canvas_layer.add_child(popup)
			popup.popup_centered()
			
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			get_tree().paused = true

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)

func set_debug_display(display_on):
	if display_on == false:
		if debug_display != null:
			debug_display.queue_free()
			debug_display = null
	else:
		if debug_display == null:
			debug_display = DEBUG_DISPLAY_SCENE.instance()
			canvas_layer.add_child(debug_display)

func popup_closed():
	get_tree().paused = false
	
	if popup != null:
		popup.queue_free()
		popup = null

func popup_quit():
	get_tree().paused = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if popup != null:
		popup.queue_free()
		popup = null
	
	load_new_scene(MAIN_MENU_PATH)