extends CharacterBody3D

## --- Movement settings ---
@export var walk_speed: float = 4.0
@export var run_speed: float = 7.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@export var acceleration: float = 10.0

## --- Nodes ---
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var mesh: MeshInstance3D = $MeshBody

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed: float = walk_speed

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if event.is_action_pressed("ui_cancel"):
		# Nhấn ESC để thoát chuột ra khỏi màn hình khi test trên PC
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Run toggle
	current_speed = run_speed if Input.is_action_pressed("run") else walk_speed

	# Input direction (WASD)
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction.length() > 0.01:
		velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
		_play_walk_bob(delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

	move_and_slide()

## Animation "nhẹ" tạm thời: nhấp nhô mesh khi đi, chưa cần rig xương thật
var _bob_time: float = 0.0
func _play_walk_bob(delta: float) -> void:
	_bob_time += delta * (10.0 if current_speed == run_speed else 6.0)
	mesh.position.y = 0.9 + sin(_bob_time) * 0.05
