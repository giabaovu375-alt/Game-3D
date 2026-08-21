extends CanvasLayer

## Virtual joystick (trái) + nút Nhảy/Chạy (phải) + vùng nhìn (kéo màn hình bên phải)
## Tự động ẩn trên desktop, chỉ hiện trên thiết bị cảm ứng.

@onready var joystick_bg: Control = $JoystickBase
@onready var joystick_knob: Control = $JoystickBase/JoystickKnob
@onready var jump_button: Button = $JumpButton
@onready var run_button: Button = $RunButton
@onready var look_area: Control = $LookArea

var _player: CharacterBody3D = null
var _joystick_touch_index: int = -1
var _joystick_origin: Vector2 = Vector2.ZERO
var _joystick_radius: float = 60.0

var _look_touch_index: int = -1
var _last_look_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	var is_touch: bool = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	visible = is_touch
	if not is_touch:
		set_process_unhandled_input(false)
		return

	_player = get_tree().get_first_node_in_group("player")
	joystick_knob.position = Vector2.ZERO

	jump_button.pressed.connect(_on_jump_pressed)
	run_button.toggled.connect(_on_run_toggled)

func _on_jump_pressed() -> void:
	if _player:
		_player.virtual_jump_pressed = true

func _on_run_toggled(is_pressed: bool) -> void:
	if _player:
		_player.virtual_run_held = is_pressed

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		var pos: Vector2 = event.position
		if event.pressed:
			if pos.x < get_viewport().get_visible_rect().size.x * 0.5 and _joystick_touch_index == -1:
				# Bắt đầu kéo joystick ở nửa trái màn hình
				_joystick_touch_index = event.index
				_joystick_origin = pos
				joystick_bg.global_position = pos - joystick_bg.size * 0.5
				joystick_bg.modulate.a = 1.0
			elif pos.x >= get_viewport().get_visible_rect().size.x * 0.5 and _look_touch_index == -1:
				_look_touch_index = event.index
				_last_look_pos = pos
		else:
			if event.index == _joystick_touch_index:
				_joystick_touch_index = -1
				joystick_knob.position = Vector2.ZERO
				if _player:
					_player.joystick_vector = Vector2.ZERO
				joystick_bg.modulate.a = 0.55
			elif event.index == _look_touch_index:
				_look_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == _joystick_touch_index:
			var offset: Vector2 = event.position - _joystick_origin
			offset = offset.limit_length(_joystick_radius)
			joystick_knob.position = offset
			if _player:
				# Convert screen-space to input vector: up = forward (negative y)
				_player.joystick_vector = Vector2(offset.x / _joystick_radius, offset.y / _joystick_radius)
		elif event.index == _look_touch_index:
			var delta: Vector2 = event.position - _last_look_pos
			_last_look_pos = event.position
			if _player and _player.has_method("apply_touch_look"):
				_player.apply_touch_look(delta)
