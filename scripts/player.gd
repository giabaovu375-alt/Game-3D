extends CharacterBody3D

## --- Movement settings ---
@export var walk_speed: float = 4.0
@export var run_speed: float = 7.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@export var touch_look_sensitivity: float = 0.006
@export var acceleration: float = 10.0

## --- Nodes ---
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var mesh: MeshInstance3D = $MeshBody

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed: float = walk_speed

## --- Mobile virtual input state (set externally by TouchControls UI) ---
## joystick_vector: -1..1 range on both axes, x = strafe, y = forward(-)/back(+)
var joystick_vector: Vector2 = Vector2.ZERO
var virtual_jump_pressed: bool = false
var virtual_run_held: bool = false

func _ready() -> void:
	if not _is_touch_device():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _is_touch_device() -> bool:
	return OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if event.is_action_pressed("ui_cancel"):
		# Nhấn ESC để thoát chuột ra khỏi màn hình khi test trên PC
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Called by TouchControls.gd when the look-pad is dragged
func apply_touch_look(delta: Vector2) -> void:
	rotate_y(-delta.x * touch_look_sensitivity)
	camera_pivot.rotate_x(-delta.y * touch_look_sensitivity)
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump (keyboard or virtual button)
	var jump_pressed: bool = Input.is_action_just_pressed("jump") or virtual_jump_pressed
	if jump_pressed and is_on_floor():
		velocity.y = jump_velocity
	virtual_jump_pressed = false

	# Run toggle (keyboard or virtual button)
	var running: bool = Input.is_action_pressed("run") or virtual_run_held
	current_speed = run_speed if running else walk_speed

	# Input direction (WASD or virtual joystick)
	var keyboard_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_dir: Vector2 = keyboard_dir
	if joystick_vector.length() > 0.01:
		input_dir = joystick_vector
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction.length() > 0.01:
		velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
		_play_walk_bob(delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		_settle_bob(delta)

	move_and_slide()

## Animation "nhẹ": nhấp nhô mesh + camera khi đi, chưa cần rig xương thật
var _bob_time: float = 0.0
func _play_walk_bob(delta: float) -> void:
	_bob_time += delta * (10.0 if current_speed == run_speed else 6.0)
	mesh.position.y = 0.9 + sin(_bob_time) * 0.05
	camera_pivot.position.y = lerp(camera_pivot.position.y, 1.6 + sin(_bob_time * 2.0) * 0.03, 8.0 * delta)

func _settle_bob(delta: float) -> void:
	mesh.position.y = lerp(mesh.position.y, 0.9, 8.0 * delta)
	camera_pivot.position.y = lerp(camera_pivot.position.y, 1.6, 8.0 * delta)
