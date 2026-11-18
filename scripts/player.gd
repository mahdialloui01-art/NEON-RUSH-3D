extends CharacterBody3D

@export var move_speed := 8.0
@export var sprint_speed := 12.0
@export var jump_velocity := 8.5
@export var gravity := 22.0
@export var slide_time := 0.65

var jumps_left := 2
var sliding := false
var slide_left := 0.0
var spawn_point := Vector3(0, 1.2, 5)
var camera_pivot: Node3D
var camera: Camera3D

func _ready() -> void:
    add_to_group("player")
    _build_player()
    global_position = spawn_point

func _build_player() -> void:
    var body := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.42
    mesh.height = 1.8
    body.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.05, 0.85, 1.0)
    material.emission_enabled = true
    material.emission = Color(0.0, 0.55, 1.0)
    material.emission_energy_multiplier = 1.8
    body.material_override = material
    body.position.y = 0.9
    add_child(body)

    var collider := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = 1.8
    collider.shape = shape
    collider.position.y = 0.9
    add_child(collider)

    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 3.2, 7.5)
    add_child(camera_pivot)
    camera = Camera3D.new()
    camera.position = Vector3(0, 0.8, 7.0)
    camera.look_at(Vector3(0, 0, -4))
    camera.current = true
    camera_pivot.add_child(camera)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        jumps_left = 2

    if Input.is_action_just_pressed("jump") and (is_on_floor() or jumps_left > 0):
        velocity.y = jump_velocity
        jumps_left -= 1

    if Input.is_action_just_pressed("slide") and is_on_floor():
        sliding = true
        slide_left = slide_time
    if sliding:
        slide_left -= delta
        if slide_left <= 0.0:
            sliding = false

    var axis := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var speed := sprint_speed if Input.is_action_pressed("sprint") else move_speed
    if sliding:
        speed *= 1.35
    var direction := Vector3(axis.x, 0.0, axis.y).normalized()
    velocity.x = move_toward(velocity.x, direction.x * speed, 28.0 * delta)
    velocity.z = move_toward(velocity.z, direction.z * speed, 28.0 * delta)
    move_and_slide()

    if global_position.y < -12.0:
        global_position = spawn_point
        velocity = Vector3.ZERO
