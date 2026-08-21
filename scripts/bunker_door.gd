extends Node3D

## Cửa hầm kim loại: trượt lên khi player vào vùng Area3D, đóng lại khi ra.
## Có đèn cảnh báo nhấp nháy nhẹ khi cửa đang chuyển động.

@export var open_offset: Vector3 = Vector3(0, 2.2, 0)
@export var move_time: float = 1.1

@onready var door_mesh: CSGBox3D = $DoorMesh
@onready var area: Area3D = $Area3D
@onready var warn_light: OmniLight3D = $WarnLight if has_node("WarnLight") else null

var closed_position: Vector3
var is_open: bool = false
var tween: Tween

func _ready() -> void:
	closed_position = door_mesh.position
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_open:
		_toggle_door(true)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and is_open:
		_toggle_door(false)

func _toggle_door(open: bool) -> void:
	is_open = open
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	var target = closed_position + open_offset if open else closed_position
	tween.tween_property(door_mesh, "position", target, move_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if warn_light:
		# Đèn cảnh báo cam nhấp nháy nhanh trong lúc cửa chuyển động rồi tắt
		tween.tween_property(warn_light, "light_energy", 1.6, move_time * 0.3).set_trans(Tween.TRANS_SINE)
		tween.chain().tween_property(warn_light, "light_energy", 0.0, move_time * 0.5)
