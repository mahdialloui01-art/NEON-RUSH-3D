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
    for i in range(platforms.size()):
        var p := platforms[i]
        if p.has_meta("moving"):
            p.position.x = float(p.get_meta("base_x")) + sin(elapsed * 1.5 + i) * 2.0
    if player.global_position.z < -38.0:
        finished = true
        hud.text = "RUN COMPLETE!   TIME %.2f s" % elapsed
    else:
        hud.text = "NEON RUSH 3D     TIME %.1f s" % elapsed

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
    _build_city()

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
    _build_touch_controls(layer)

func _build_touch_controls(layer: CanvasLayer) -> void:
    var size := get_viewport().get_visible_rect().size
    _touch_button(layer, "move_left", Vector2(76, size.y - 105), "◀")
    _touch_button(layer, "move_right", Vector2(184, size.y - 105), "▶")
    _touch_button(layer, "move_forward", Vector2(130, size.y - 164), "▲")
    _touch_button(layer, "move_back", Vector2(130, size.y - 48), "▼")
    _touch_button(layer, "jump", Vector2(size.x - 165, size.y - 145), "JUMP")
    _touch_button(layer, "sprint", Vector2(size.x - 70, size.y - 78), "RUN")
    _touch_button(layer, "slide", Vector2(size.x - 260, size.y - 65), "SLIDE")

func _touch_button(layer: CanvasLayer, action: String, pos: Vector2, caption: String) -> void:
    var button := TouchScreenButton.new()
    button.action = action
    button.position = pos
    var hit := CircleShape2D.new()
    hit.radius = 38.0
    button.shape = hit
    layer.add_child(button)

    var label := Label.new()
    label.text = caption
    label.position = pos - Vector2(42, 16)
    label.add_theme_font_size_override("font_size", 18 if caption.length() < 4 else 13)
    label.add_theme_color_override("font_color", Color(0.35, 0.95, 1.0))
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(label)

func _build_city() -> void:
    # Lightweight procedural skyline: simple meshes, shared materials, no collision.
    var building_material := StandardMaterial3D.new()
    building_material.albedo_color = Color(0.025, 0.035, 0.09)
    building_material.metallic = 0.35
    building_material.roughness = 0.72

    var cyan_material := StandardMaterial3D.new()
    cyan_material.albedo_color = Color(0.0, 0.65, 0.9)
    cyan_material.emission_enabled = true
    cyan_material.emission = Color(0.0, 0.55, 1.0)
    cyan_material.emission_energy_multiplier = 1.4

    var violet_material := StandardMaterial3D.new()
    violet_material.albedo_color = Color(0.48, 0.12, 0.85)
    violet_material.emission_enabled = true
    violet_material.emission = Color(0.38, 0.05, 0.9)
    violet_material.emission_energy_multiplier = 1.2

    for side in [-1.0, 1.0]:
        for i in range(14):
            var height := 7.0 + float((i * 7 + int(side)) % 6) * 2.1
            var depth := 3.0
            var width := 3.2 + float(i % 2) * 0.8
            var z := 5.0 - float(i) * 3.7
            var x := side * (7.5 + float(i % 3) * 1.15)

            var building := MeshInstance3D.new()
            var block := BoxMesh.new()
            block.size = Vector3(width, height, depth)
            building.mesh = block
            building.position = Vector3(x, height * 0.5 - 0.15, z)
            building.material_override = building_material
            add_child(building)

            # A few emissive facade bands create the neon-city look cheaply.
            for band in range(1, int(height / 2.4)):
                var strip := MeshInstance3D.new()
                var strip_mesh := BoxMesh.new()
                strip_mesh.size = Vector3(width * 0.78, 0.055, 0.045)
                strip.mesh = strip_mesh
                strip.position = Vector3(
                    x,
                    float(band) * 2.4,
                    z + (depth * 0.5 + 0.03) * (-side)
                )
                strip.material_override = cyan_material if (i + band) % 2 == 0 else violet_material
                add_child(strip)
