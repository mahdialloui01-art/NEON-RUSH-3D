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
    # Lightweight procedural runner model: primitive meshes, shared materials,
    # and no imported textures, so it stays small on Android.
    var suit := StandardMaterial3D.new()
    suit.albedo_color = Color(0.025, 0.045, 0.11)
    suit.metallic = 0.25
    suit.roughness = 0.55

    var armor := StandardMaterial3D.new()
    armor.albedo_color = Color(0.04, 0.12, 0.22)
    armor.metallic = 0.55
    armor.roughness = 0.38

    var glow := StandardMaterial3D.new()
    glow.albedo_color = Color(0.0, 0.8, 1.0)
    glow.emission_enabled = true
    glow.emission = Color(0.0, 0.65, 1.0)
    glow.emission_energy_multiplier = 2.0

    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color(0.72, 0.52, 0.38)
    skin.roughness = 0.8

    var visual := Node3D.new()
    visual.name = "RunnerVisual"
    add_child(visual)

    var torso_mesh := CapsuleMesh.new()
    torso_mesh.radius = 0.29
    torso_mesh.height = 0.88
    _part(visual, torso_mesh, Vector3(0, 1.12, 0), suit)

    var chest_mesh := BoxMesh.new()
    chest_mesh.size = Vector3(0.58, 0.24, 0.24)
    _part(visual, chest_mesh, Vector3(0, 1.34, -0.015), armor)

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.22
    head_mesh.height = 0.44
    _part(visual, head_mesh, Vector3(0, 1.78, 0), skin)

    var visor_mesh := BoxMesh.new()
    visor_mesh.size = Vector3(0.31, 0.075, 0.08)
    _part(visual, visor_mesh, Vector3(0, 1.81, -0.19), glow)

    var shoulder_mesh := SphereMesh.new()
    shoulder_mesh.radius = 0.16
    shoulder_mesh.height = 0.32
    _part(visual, shoulder_mesh, Vector3(-0.39, 1.37, 0), armor)
    _part(visual, shoulder_mesh, Vector3(0.39, 1.37, 0), armor)

    var arm_mesh := CapsuleMesh.new()
    arm_mesh.radius = 0.105
    arm_mesh.height = 0.62
    _part(visual, arm_mesh, Vector3(-0.4, 1.02, 0), suit)
    _part(visual, arm_mesh, Vector3(0.4, 1.02, 0), suit)

    var leg_mesh := CapsuleMesh.new()
    leg_mesh.radius = 0.13
    leg_mesh.height = 0.72
    _part(visual, leg_mesh, Vector3(-0.17, 0.48, 0), armor)
    _part(visual, leg_mesh, Vector3(0.17, 0.48, 0), armor)

    var boot_mesh := BoxMesh.new()
    boot_mesh.size = Vector3(0.25, 0.14, 0.38)
    _part(visual, boot_mesh, Vector3(-0.17, 0.12, -0.075), glow)
    _part(visual, boot_mesh, Vector3(0.17, 0.12, -0.075), glow)

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

func _part(parent: Node3D, mesh: Mesh, pos: Vector3, material: Material) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.position = pos
    instance.material_override = material
    parent.add_child(instance)
    return instance

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
