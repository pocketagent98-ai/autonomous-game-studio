## The runner. CharacterBody3D with a full state machine, keyboard + swipe input.
class_name Player
extends CharacterBody3D

signal died

enum State { IDLE, RUNNING, JUMPING, SLIDING, TURNING_LEFT, TURNING_RIGHT, STUMBLE, DEAD }

@export var player_height: float = 1.8
@export var player_radius: float = 0.4
@export var jump_velocity: float = 9.0
@export var slide_duration: float = 0.55
@export var turn_duration: float = 0.14
@export var lane_width: float = 2.0

const SWIPE_THRESHOLD := 40.0

var state: State = State.IDLE
var lane_idx: int = 1
var lanes: Array = []
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _mesh: MeshInstance3D
var _col: CollisionShape3D
var _turn_tween: Tween
var _slide_tween: Tween
var _input_start: Vector2 = Vector2.ZERO
var _input_active: bool = false


func _ready() -> void:
    lanes = [-lane_width, 0.0, lane_width]
    _build()
    add_to_group("player")
    Game.run_reset.connect(_on_run_reset)
    Game.run_over.connect(_on_run_over)
    reset_player()


func _build() -> void:
    _mesh = MeshInstance3D.new()
    var cap := CapsuleMesh.new()
    cap.height = player_height
    cap.radius = player_radius
    var m := StandardMaterial3D.new()
    m.albedo_color = Color("#ff5c7a")
    m.roughness = 0.6
    cap.material = m
    _mesh.mesh = cap
    add_child(_mesh)

    _col = CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.height = player_height
    shape.radius = player_radius
    _col.shape = shape
    add_child(_col)


func _physics_process(delta: float) -> void:
    if state == State.DEAD:
        velocity = Vector3.ZERO
        return
    if not is_on_floor():
        velocity.y -= gravity * delta
    if state == State.IDLE:
        velocity.z = 0.0
    else:
        var s: float = Game.speed
        velocity.z = -s
        if state != State.JUMPING:
            Game.add_distance(s * delta)
    if state == State.JUMPING and is_on_floor() and velocity.y <= 0.0:
        _set_state(State.RUNNING)
    move_and_slide()


func _input(event: InputEvent) -> void:
    if state == State.DEAD:
        return
    if event is InputEventKey and event.pressed and not event.echo:
        match event.physical_keycode:
            KEY_A, KEY_LEFT:
                _act("left")
            KEY_D, KEY_RIGHT:
                _act("right")
            KEY_W, KEY_UP, KEY_SPACE:
                _act("jump")
            KEY_S, KEY_DOWN:
                _act("slide")
    elif event is InputEventScreenTouch:
        if event.pressed:
            _input_start = event.position
            _input_active = true
        else:
            _input_active = false
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _input_start = event.position
            _input_active = true
        else:
            _input_active = false
    elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and _input_active:
        var d: Vector2 = event.position - _input_start
        if d.length() > SWIPE_THRESHOLD:
            _input_active = false
            if absf(d.x) > absf(d.y):
                _act("left" if d.x < 0.0 else "right")
            else:
                _act("jump" if d.y < 0.0 else "slide")


func _act(a: String) -> void:
    if not Game.is_running:
        if state == State.IDLE:
            Game.start_run()
            _set_state(State.RUNNING)
            match a:
                "jump":
                    _do_jump()
                "slide":
                    _do_slide()
                "left":
                    _do_turn(-1)
                "right":
                    _do_turn(1)
        return
    if state == State.RUNNING or state == State.JUMPING or state == State.TURNING_LEFT or state == State.TURNING_RIGHT:
        match a:
            "jump":
                _do_jump()
            "slide":
                _do_slide()
            "left":
                _do_turn(-1)
            "right":
                _do_turn(1)
    elif state == State.SLIDING:
        match a:
            "left":
                _do_turn(-1)
            "right":
                _do_turn(1)


func _do_jump() -> void:
    if state == State.SLIDING:
        return
    if is_on_floor():
        velocity.y = jump_velocity
        _set_state(State.JUMPING)
        Audio.play_jump()


func _do_slide() -> void:
    if state == State.SLIDING:
        return
    _set_state(State.SLIDING)
    if _slide_tween and _slide_tween.is_valid():
        _slide_tween.kill()
    var target_h := player_height * 0.5
    var off := (player_height - target_h) * 0.5
    _slide_tween = create_tween()
    _slide_tween.set_parallel(true)
    _slide_tween.tween_property(_mesh.mesh, "height", target_h, 0.12)
    _slide_tween.tween_property(_col.shape, "height", target_h, 0.12)
    _slide_tween.tween_property(_mesh, "position:y", -off, 0.12)
    _slide_tween.tween_property(_col, "position:y", -off, 0.12)
    _slide_tween.chain().tween_interval(slide_duration)
    _slide_tween.tween_callback(_end_slide)


func _end_slide() -> void:
    if state != State.SLIDING:
        return
    if _slide_tween and _slide_tween.is_valid():
        _slide_tween.kill()
    _slide_tween = create_tween()
    _slide_tween.set_parallel(true)
    _slide_tween.tween_property(_mesh.mesh, "height", player_height, 0.12)
    _slide_tween.tween_property(_col.shape, "height", player_height, 0.12)
    _slide_tween.tween_property(_mesh, "position:y", 0.0, 0.12)
    _slide_tween.tween_property(_col, "position:y", 0.0, 0.12)
    _slide_tween.chain().tween_callback(func() -> void: _set_state(State.RUNNING))


func _do_turn(dir: int) -> void:
    var ni := lane_idx + dir
    if ni < 0 or ni > 2:
        return
    lane_idx = ni
    if _turn_tween and _turn_tween.is_valid():
        _turn_tween.kill()
    _turn_tween = create_tween()
    _turn_tween.tween_property(self, "position:x", lanes[lane_idx], turn_duration)
    _set_state(State.TURNING_LEFT if dir < 0 else State.TURNING_RIGHT)
    _turn_tween.tween_callback(_end_turn)


func _end_turn() -> void:
    if state == State.TURNING_LEFT or state == State.TURNING_RIGHT:
        if (_mesh.mesh as CapsuleMesh).height < player_height - 0.05:
            _set_state(State.SLIDING)
        else:
            _set_state(State.RUNNING)


func die() -> void:
    if state == State.DEAD:
        return
    Audio.play_hit()
    _set_state(State.DEAD)


func _set_state(s: State) -> void:
    if state == s:
        return
    state = s
    if s == State.DEAD:
        velocity = Vector3.ZERO
        died.emit()
        Game.end_run()


func reset_player() -> void:
    if _turn_tween and _turn_tween.is_valid():
        _turn_tween.kill()
    if _slide_tween and _slide_tween.is_valid():
        _slide_tween.kill()
    if _mesh:
        (_mesh.mesh as CapsuleMesh).height = player_height
        (_mesh.mesh as CapsuleMesh).radius = player_radius
        _mesh.position = Vector3.ZERO
    if _col:
        (_col.shape as CapsuleShape3D).height = player_height
        (_col.shape as CapsuleShape3D).radius = player_radius
        _col.position = Vector3.ZERO
    lane_idx = 1
    position = Vector3(lanes[lane_idx], player_height * 0.5, 0.0)
    velocity = Vector3.ZERO
    state = State.IDLE


func _on_run_reset() -> void:
    reset_player()


func _on_run_over(_score: int, _best: int) -> void:
    if state != State.DEAD:
        state = State.DEAD
