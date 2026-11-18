extends Node3D

var player: CharacterBody3D
var hud: Label
var elapsed := 0.0
var finished := false
var platforms: Array[Node3D] = []

func _ready() -> void:
    _setup_input()
    _build_world()
    player = get_node("Player")
    _build_hud()

func _process(delta: float) -> void:
    if finished:
        return
    elapsed += delta
    for i in platforms.size():
        var p := platforms[i]
        if p.has_meta("moving"):
            p.position.x = float(p.get_meta("base_x")) + sin(elapsed * 1.5 + i) * 2.0
    if player.global_position.z < -38.0:
        finished = true
        hud.text = "RUN COMPLETE!   TIME %.2f s" % elapsed
    elif player.global_position.y < -10.0:
        hud.text = "CHECKPOINT  •  %.1f s" % elapsed
    else:
        hud.text = "NEON RUSH 3D     TIME %.1f s     DOUBLE JUMP: ON" % elapsed

func _setup_input() -> void:
    _key_action("move_left", KEY_A)
    _key_action("move_right", KEY_D)
    _key_action("move_forward", KEY_W)
    _key_action("move_back", KEY_S)
    _key_action("jump", KEY_SPACE)
    _key_action("sprint", KEY_SHIFT)
    _key_action("slide", KEY_CTRL)

func _key_action(action: String, key: Key) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventKey.new()
    event.physical_keycode = key
    InputMap.action_add_event(action, event)

func _build_world() -> void:
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.08, 0.1, 0.22)
    env.ambient_light_energy = 0.8
    environment.environment = env
    add_child(environment)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

    _platform(Vector3(0, -0.5, 4), Vector3(9, 1, 12), Color(0.07, 0.1, 0.2))
    for i in range(1, 13):
        var x := sin(float(i) * 0.8) * 2.2
        var z := 4.0 - float(i) * 3.6
        var p := _platform(Vector3(x, 0, z), Vector3(4.2, 0.7, 3.0), Color(0.04, 0.22, 0.34))
        if i % 3 == 0:
            p.set_meta("moving", true)
            p.set_meta("base_x", x)
        if i == 6:
            _checkpoint(Vector3(x, 1.0, z))
    _platform(Vector3(0, 0, -42), Vector3(12, 1, 10), Color(0.0, 0.3, 0.24))

    for i in range(0, 8):
        var beam := _platform(Vector3(sin(float(i)) * 1.8, 1.1, -8.0 - i * 5.0), Vector3(0.18, 0.18, 2.2), Color(1.0, 0.08, 0.28))
        beam.rotation_degrees.z = 0
        beam.name = "NeonHazard"

func _platform(pos: Vector3, size: Vector3, color: Color) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.position = pos
    add_child(body)
    var mesh_instance := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh_instance.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 0.7
    mesh_instance.material_override = mat
    body.add_child(mesh_instance)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
    platforms.append(body)
    return body

func _checkpoint(pos: Vector3) -> void:
    var marker := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.45
    sphere.height = 0.9
    marker.mesh = sphere
    marker.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.2, 1.0, 0.45)
    mat.emission_enabled = true
    mat.emission = Color(0.1, 1.0, 0.35)
    marker.material_override = mat
    add_child(marker)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(24, 20)
    hud.add_theme_font_size_override("font_size", 22)
    hud.add_theme_color_override("font_color", Color(0.2, 0.95, 1.0))
    layer.add_child(hud)
    hud.text = "NEON RUSH 3D"
