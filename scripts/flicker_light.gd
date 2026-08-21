extends OmniLight3D

## Đèn nhấp nháy kiểu hầm hỏng - animation nhẹ không cần AnimationPlayer

@export var min_energy: float = 0.3
@export var max_energy: float = 1.5
@export var flicker_speed: float = 8.0
@export var flicker_chance: float = 0.1  # xác suất giật mỗi frame check

var _rng := RandomNumberGenerator.new()
var _timer: float = 0.0

func _ready() -> void:
	_rng.randomize()

func _process(delta: float) -> void:
	_timer += delta
	if _timer > 0.05:
		_timer = 0.0
		if _rng.randf() < flicker_chance:
			light_energy = _rng.randf_range(min_energy, max_energy)
		else:
			light_energy = lerp(light_energy, max_energy, delta * flicker_speed)
