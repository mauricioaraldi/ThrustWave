extends RigidBody3D

## How much vertical force to apply when moving
@export_range(500.0, 3000.0) var thrust: float = 1000.0

## How much torque is applied when rotating
@export_range(50.0, 200.0) var torque: float = 100.0

var _has_crashed: bool = false
var _has_completed: bool = false

@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound
@onready var success_sound: AudioStreamPlayer = $SuccessSound
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles_center: GPUParticles3D = $Model/CenterThrust/BoosterParticles_center
@onready var booster_particles_right: GPUParticles3D = $Model/RightThrust/BoosterParticles_right
@onready var booster_particles_left: GPUParticles3D = $Model/LeftThrust/BoosterParticles_left
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles


func _process(delta: float) -> void:
  if Input.is_action_pressed("boost"):
    apply_central_force(basis.y * delta * thrust)
  if (Input.is_action_just_pressed("boost")):
    rocket_audio.play()
    booster_particles_center.emitting = true;
  if Input.is_action_just_released("boost"):
    rocket_audio.stop()
    booster_particles_center.emitting = false;

  if Input.is_action_pressed("rotate_left"):
    apply_torque(Vector3(0, 0, torque * delta))
  if (Input.is_action_just_pressed("rotate_left")):
    booster_particles_right.emitting = true;
  if Input.is_action_just_released("rotate_left"):
    booster_particles_right.emitting = false;

  if Input.is_action_pressed("rotate_right"):
    apply_torque(Vector3(0, 0, -torque * delta))
  if (Input.is_action_just_pressed("rotate_right")):
    booster_particles_left.emitting = true;
  if Input.is_action_just_released("rotate_right"):
    booster_particles_left.emitting = false;


func _on_body_entered(body: Node) -> void:
  if "Goal" in body.get_groups() && !_has_completed:
    complete_level(body.next_scene)

  if "Untouchable" in body.get_groups() && !_has_crashed:
    crash_sequence()


func crash_sequence() -> void:
  _has_crashed = true
  set_process(false)
  explosion_sound.play()
  explosion_particles.emitting = true;
  booster_particles_center.emitting = false;
  booster_particles_left.emitting = false;
  booster_particles_right.emitting = false;

  var tween = create_tween()
  tween.tween_interval(2.0)
  tween.tween_callback(get_tree().reload_current_scene)


func complete_level(next_level_file: String) -> void:
  _has_completed = true
  set_process(false)
  success_sound.play()
  success_particles.emitting = true;
  booster_particles_center.emitting = false;
  booster_particles_left.emitting = false;
  booster_particles_right.emitting = false;

  var tween = create_tween()
  tween.tween_interval(1.5)
  tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
