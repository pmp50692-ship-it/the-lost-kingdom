extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const JoystickScript = preload("res://scripts/touch_joystick.gd")
var hero: CharacterBody3D

func _ready() -> void:
    _setup_input()
    _build_environment()
    _spawn_player()
    _build_mobile_controls()

func _setup_input() -> void:
    _add_key_action("move_forward", KEY_W)
    _add_key_action("move_back", KEY_S)
    _add_key_action("move_left", KEY_A)
    _add_key_action("move_right", KEY_D)
    _add_key_action("jump", KEY_SPACE)

func _add_key_action(action: String, key: Key) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    var event := InputEventKey.new()
    event.physical_keycode = key
    InputMap.action_add_event(action, event)

func _material(color: Color, roughness: float = 0.82, metallic: float = 0.0) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = roughness
    mat.metallic = metallic
    return mat

func gold_material() -> StandardMaterial3D:
    return _material(Color(0.83, 0.59, 0.20), 0.38, 0.55)

func _add_box(pos: Vector3, dimensions: Vector3, color: Color) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.position = pos
    add_child(body)
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    mesh_instance.mesh = mesh
    mesh_instance.material_override = _material(color)
    body.add_child(mesh_instance)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = dimensions
    collision.shape = shape
    body.add_child(collision)
    return body

func _build_environment() -> void:
    var world_env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color(0.10, 0.30, 0.62)
    sky_material.sky_horizon_color = Color(0.72, 0.78, 0.88)
    sky_material.ground_bottom_color = Color(0.12, 0.10, 0.09)
    sky_material.ground_horizon_color = Color(0.48, 0.43, 0.35)
    sky_material.sun_angle_max = 18.0
    sky_material.sun_curve = 0.12
    sky.sky_material = sky_material
    environment.sky = sky
    environment.background_mode = Environment.BG_SKY
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    environment.ambient_light_energy = 0.85
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.tonemap_exposure = 1.0
    environment.glow_enabled = true
    environment.glow_intensity = 0.35
    environment.glow_strength = 0.7
    environment.ssao_enabled = true
    environment.ssao_radius = 2.0
    environment.ssao_intensity = 1.1
    world_env.environment = environment
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_color = Color(1.0, 0.83, 0.62)
    sun.light_energy = 1.45
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 55.0
    add_child(sun)

    var ground := _add_box(Vector3(0, -0.5, 0), Vector3(70, 1, 70), Color(0.25, 0.31, 0.18))
    var stone := Color(0.58, 0.42, 0.27)
    var sandstone := Color(0.72, 0.56, 0.37)
    var dark_stone := Color(0.36, 0.24, 0.15)
    # Grand royal temple entrance with layered steps and carved-looking trim
    _add_box(Vector3(0, 0.12, -9.5), Vector3(13, 0.28, 7), dark_stone)
    for i in range(4):
        _add_box(Vector3(0, 0.22 + float(i) * 0.20, -7.4 - float(i) * 0.72), Vector3(9.5 - float(i) * 0.8, 0.22, 1.1), sandstone)
    _add_box(Vector3(-5, 2.3, -12), Vector3(1.25, 4.6, 1.25), stone)
    _add_box(Vector3(5, 2.3, -12), Vector3(1.25, 4.6, 1.25), stone)
    _add_box(Vector3(0, 4.6, -12), Vector3(12, 1.1, 2.0), sandstone)
    _add_box(Vector3(0, 3.95, -12), Vector3(8.5, 0.18, 2.15), dark_stone)
    _add_box(Vector3(0, 5.25, -12), Vector3(13, 0.35, 2.3), stone)
    # Decorative column bases, capitals and gold inlay bands
    for side in [-1.0, 1.0]:
        for z_offset in [0.0, -3.0]:
            var px: float = side * 5.0
            var pz: float = -12.0 + z_offset
            _add_box(Vector3(px, 0.35, pz), Vector3(1.8, 0.45, 1.8), dark_stone)
            _add_box(Vector3(px, 0.62, pz), Vector3(1.35, 0.16, 1.35), sandstone)
            _add_box(Vector3(px, 2.6, pz), Vector3(1.15, 3.9, 1.15), stone)
            _add_box(Vector3(px, 4.55, pz), Vector3(1.65, 0.32, 1.65), sandstone)
            _add_box(Vector3(px, 4.78, pz), Vector3(1.35, 0.12, 1.35), Color(0.83, 0.59, 0.20))
            _add_box(Vector3(px, 1.0, pz - 0.59), Vector3(0.9, 0.12, 0.08), sandstone)
    # Tall ceremonial side walls and royal banners
    _add_box(Vector3(-8.0, 1.8, -14.5), Vector3(1.0, 3.6, 8.0), dark_stone)
    _add_box(Vector3(8.0, 1.8, -14.5), Vector3(1.0, 3.6, 8.0), dark_stone)
    _add_box(Vector3(-8.0, 3.8, -14.5), Vector3(1.3, 0.25, 8.4), sandstone)
    _add_box(Vector3(8.0, 3.8, -14.5), Vector3(1.3, 0.25, 8.4), sandstone)

    for i in range(6):
        var x := -12.0 + float(i) * 4.8
        _add_box(Vector3(x, 1.2, -22), Vector3(1.1, 2.4, 1.1), Color(0.5, 0.39, 0.28))
        _add_box(Vector3(x, 2.55, -22), Vector3(1.6, 0.35, 1.6), Color(0.68, 0.52, 0.34))

    for i in range(10):
        var x := -22.0 + float(i % 5) * 11.0
        var z := -4.0 - float(i / 5) * 17.0
        _add_box(Vector3(x, 1.2, z), Vector3(0.7, 2.4, 0.7), Color(0.28, 0.18, 0.1))
        var crown := MeshInstance3D.new()
        var crown_mesh := SphereMesh.new()
        crown_mesh.radius = 2.0
        crown_mesh.height = 3.2
        crown.mesh = crown_mesh
        crown.position = Vector3(x, 3.5, z)
        crown.material_override = _material(Color(0.16, 0.31, 0.16))
        add_child(crown)

func _spawn_player() -> void:
    hero = PlayerScript.new()
    hero.name = "Hero"
    hero.position = Vector3(0, 0.1, 5)
    add_child(hero)

func _build_mobile_controls() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var joystick := Control.new()
    joystick.set_script(JoystickScript)
    joystick.anchor_left = 0.03
    joystick.anchor_top = 0.66
    joystick.anchor_right = 0.03
    joystick.anchor_bottom = 0.66
    joystick.offset_right = 190
    joystick.offset_bottom = 190
    layer.add_child(joystick)
    joystick.value_changed.connect(_on_joystick_changed)

    var attack_button := Button.new()
    attack_button.text = "ATTACK"
    attack_button.custom_minimum_size = Vector2(120, 72)
    attack_button.anchor_left = 1.0
    attack_button.anchor_top = 1.0
    attack_button.anchor_right = 1.0
    attack_button.anchor_bottom = 1.0
    attack_button.offset_left = -150
    attack_button.offset_top = -115
    attack_button.offset_right = -25
    attack_button.offset_bottom = -35
    attack_button.add_theme_font_size_override("font_size", 20)
    layer.add_child(attack_button)
    attack_button.pressed.connect(hero.attack)

    var title := Label.new()
    title.text = "THE LOST KINGDOM  |  Ancient Temple"
    title.position = Vector2(24, 18)
    title.add_theme_font_size_override("font_size", 22)
    layer.add_child(title)

func _on_joystick_changed(value: Vector2) -> void:
    if is_instance_valid(hero):
        hero.move_input = value
