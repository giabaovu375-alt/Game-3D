extends OmniLight3D

## Đèn khẩn cấp kiểu hầm trú ẩn: hầu hết thời gian sáng ổn định ấm áp,
## thỉnh thoảng giật nhẹ kiểu điện chập chờn (animation nhẹ, không cần AnimationPlayer)

@export var base_energy: float = 2.2
@export var min_energy: float = 0.6
@export var max_energy: float = 2.6
@export var flicker_speed: float = 10.0
@export var flicker_chance: float = 0.04  # xác suất giật mỗi lần check (giảm để bớt chớp tắt liên tục)

var _rng := RandomNumberGenerator.new()
var _timer: float = 0.0
var _breathe_time: float = 0.0

func _ready() -> void:
	_rng.randomize()
	_breathe_time = _rng.randf_range(0.0, 10.0)
	light_energy = base_energy

func _process(delta: float) -> void:
	_timer += delta
	_breathe_time += delta

	# Animation nhẹ: đèn "thở" sáng/tối rất nhẹ liên tục cho cảm giác sống động
	var breathe: float = sin(_breathe_time * 0.6) * 0.08

	if _timer > 0.05:
		_timer = 0.0
		if _rng.randf() < flicker_chance:
			light_energy = _rng.randf_range(min_energy, max_energy)
	light_energy = lerp(light_energy, base_energy + breathe, delta * flicker_speed * 0.3)
