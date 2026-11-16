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

func _material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.95
    return mat

func _add_box(pos: Vector3, dimensions: Vector3, color: Color) -> void:
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

func _build_environment() -> void:
    var world_env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.65, 0.68, 0.75)
    environment.ambient_light_energy = 0.7
    world_env.environment = environment
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_energy = 1.25
    add_child(sun)

    _add_box(Vector3(0, -0.5, 0), Vector3(70, 1, 70), Color(0.32, 0.38, 0.22))
    var stone := Color(0.58, 0.42, 0.27)
    _add_box(Vector3(-5, 2, -12), Vector3(2, 4, 2), stone)
    _add_box(Vector3(5, 2, -12), Vector3(2, 4, 2), stone)
    _add_box(Vector3(0, 4.2, -12), Vector3(12, 1, 2), stone)
    _add_box(Vector3(0, 0.25, -12), Vector3(8, 0.5, 2), Color(0.42, 0.29, 0.18))

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
