extends RigidBody3D

## How much vertical force to apply when moving
@export_range(500.0, 3000.0) var thrust: float = 1000.0

## How much torque is applied when rotating
@export_range(50.0, 200.0) var torque: float = 100.0

var _has_crashed: bool = false
var _has_completed: bool = false

func _process(delta: float) -> void:
  if Input.is_action_pressed("boost"):
    apply_central_force(basis.y * delta * thrust)

  if Input.is_action_pressed("rotate_left"):
    apply_torque(Vector3(0, 0, torque * delta))

  if Input.is_action_pressed("rotate_right"):
    apply_torque(Vector3(0, 0, -torque * delta))


func _on_body_entered(body: Node) -> void:
  if "Goal" in body.get_groups() && !_has_completed:
    complete_level(body.next_scene)

  if "Untouchable" in body.get_groups() && !_has_crashed:
    crash_sequence()


func crash_sequence() -> void:
  _has_crashed = true
  set_process(false)

  var tween = create_tween()
  tween.tween_interval(1.0)
  tween.tween_callback(get_tree().reload_current_scene)


func complete_level(next_level_file: String) -> void:
  _has_completed = true;
  set_process(false)

  var tween = create_tween()
  tween.tween_interval(1.0)
  tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
