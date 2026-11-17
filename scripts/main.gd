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

    _add_box(Vector3(0, -0.5, 0), Vector3(100, 1, 100), Color(0.25, 0.31, 0.18))
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

    # Royal city approach: broad sandstone avenue and ceremonial courtyard
    _add_box(Vector3(0, 0.03, -22.0), Vector3(22, 0.16, 18), Color(0.61, 0.48, 0.34))
    for side in [-1.0, 1.0]:
        _add_box(Vector3(side * 10.6, 0.18, -22.0), Vector3(0.32, 0.22, 18), Color(0.82, 0.63, 0.30))
        for j in range(5):
            _add_box(Vector3(side * 9.2, 0.55, -15.0 - float(j) * 3.0), Vector3(0.55, 1.1, 0.55), sandstone)
            _add_box(Vector3(side * 9.2, 1.16, -15.0 - float(j) * 3.0), Vector3(0.9, 0.18, 0.9), Color(0.83, 0.59, 0.20))

    # Grand palace: wings, central audience hall and a tall ceremonial doorway
    _add_box(Vector3(0, 2.8, -32.0), Vector3(22, 5.6, 2.2), sandstone)
    _add_box(Vector3(-7.1, 3.2, -30.75), Vector3(7.8, 6.4, 0.7), stone)
    _add_box(Vector3(7.1, 3.2, -30.75), Vector3(7.8, 6.4, 0.7), stone)
    _add_box(Vector3(0, 6.0, -30.75), Vector3(7.0, 1.0, 0.8), Color(0.83, 0.59, 0.20))
    _add_box(Vector3(0, 2.15, -30.55), Vector3(4.6, 4.3, 0.35), dark_stone)
    _add_box(Vector3(0, 2.05, -30.30), Vector3(3.5, 4.0, 0.12), Color(0.25, 0.10, 0.06))
    _add_box(Vector3(0, 4.25, -30.20), Vector3(5.2, 0.42, 0.35), Color(0.83, 0.59, 0.20))
    # Monumental carved royal doorway with two open golden door leaves
    _add_box(Vector3(-2.0, 2.05, -30.02), Vector3(0.16, 4.0, 0.22), Color(0.83, 0.59, 0.20))
    _add_box(Vector3(2.0, 2.05, -30.02), Vector3(0.16, 4.0, 0.22), Color(0.83, 0.59, 0.20))
    _add_box(Vector3(0, 4.12, -30.02), Vector3(4.2, 0.18, 0.25), Color(0.90, 0.68, 0.29))
    _add_box(Vector3(-1.55, 2.0, -30.12), Vector3(0.82, 3.65, 0.10), Color(0.43, 0.12, 0.055))
    _add_box(Vector3(1.55, 2.0, -30.12), Vector3(0.82, 3.65, 0.10), Color(0.43, 0.12, 0.055))
    for side in [-1.0, 1.0]:
        for y in [0.8, 1.7, 2.6, 3.45]:
            _add_box(Vector3(side * 1.55, y, -30.04), Vector3(0.58, 0.045, 0.035), Color(0.91, 0.69, 0.30))
        var door_knob := MeshInstance3D.new()
        var knob_mesh := SphereMesh.new()
        knob_mesh.radius = 0.10
        knob_mesh.height = 0.10
        door_knob.mesh = knob_mesh
        door_knob.position = Vector3(side * 1.35, 2.0, -29.94)
        door_knob.material_override = gold_material()
        add_child(door_knob)

    # Twin royal lion guardians on carved stone plinths
    for side in [-1.0, 1.0]:
        var lion_x: float = side * 6.7
        _add_box(Vector3(lion_x, 0.35, -9.0), Vector3(2.0, 0.55, 2.0), dark_stone)
        _add_box(Vector3(lion_x, 0.68, -9.0), Vector3(1.65, 0.16, 1.65), Color(0.83, 0.59, 0.20))
        var lion_mane := MeshInstance3D.new()
        var mane_mesh := SphereMesh.new()
        mane_mesh.radius = 0.72
        mane_mesh.height = 1.05
        lion_mane.mesh = mane_mesh
        lion_mane.position = Vector3(lion_x, 1.45, -9.0)
        lion_mane.material_override = _material(Color(0.66, 0.39, 0.16))
        add_child(lion_mane)
        var lion_head := MeshInstance3D.new()
        var head_mesh := SphereMesh.new()
        head_mesh.radius = 0.43
        head_mesh.height = 0.62
        lion_head.mesh = head_mesh
        lion_head.position = Vector3(lion_x, 1.82, -9.42)
        lion_head.material_override = _material(Color(0.79, 0.55, 0.27))
        add_child(lion_head)
        for ear_side in [-1.0, 1.0]:
            var ear := MeshInstance3D.new()
            var ear_mesh := SphereMesh.new()
            ear_mesh.radius = 0.16
            ear_mesh.height = 0.20
            ear.mesh = ear_mesh
            ear.position = Vector3(lion_x + ear_side * 0.34, 2.12, -9.42)
            ear.material_override = _material(Color(0.79, 0.55, 0.27))
            add_child(ear)
        var muzzle := MeshInstance3D.new()
        var muzzle_mesh := SphereMesh.new()
        muzzle_mesh.radius = 0.22
        muzzle_mesh.height = 0.20
        muzzle.mesh = muzzle_mesh
        muzzle.position = Vector3(lion_x, 1.62, -9.80)
        muzzle.material_override = _material(Color(0.91, 0.72, 0.43))
        add_child(muzzle)
        for leg_side in [-1.0, 1.0]:
            _add_box(Vector3(lion_x + leg_side * 0.34, 0.98, -8.72), Vector3(0.24, 0.62, 0.28), Color(0.66, 0.39, 0.16))

    # Twin ornamental fountains in the palace forecourt, leaving the central path clear
    for side in [-1.0, 1.0]:
        var fx: float = side * 7.2
        _add_box(Vector3(fx, 0.18, -21.5), Vector3(3.2, 0.36, 3.2), dark_stone)
        _add_box(Vector3(fx, 0.40, -21.5), Vector3(2.8, 0.16, 2.8), Color(0.83, 0.59, 0.20))
        var basin := MeshInstance3D.new()
        var basin_mesh := CylinderMesh.new()
        basin_mesh.top_radius = 1.25
        basin_mesh.bottom_radius = 1.05
        basin_mesh.height = 0.48
        basin.mesh = basin_mesh
        basin.position = Vector3(fx, 0.70, -21.5)
        basin.material_override = _material(Color(0.60, 0.48, 0.36))
        add_child(basin)
        var water := MeshInstance3D.new()
        var water_mesh := CylinderMesh.new()
        water_mesh.top_radius = 0.94
        water_mesh.bottom_radius = 0.94
        water_mesh.height = 0.06
        water.mesh = water_mesh
        water.position = Vector3(fx, 0.96, -21.5)
        water.material_override = _material(Color(0.12, 0.48, 0.68), 0.18, 0.25)
        add_child(water)
        _add_box(Vector3(fx, 1.22, -21.5), Vector3(0.22, 0.62, 0.22), Color(0.83, 0.59, 0.20))
        var fountain_top := MeshInstance3D.new()
        var top_mesh := SphereMesh.new()
        top_mesh.radius = 0.34
        top_mesh.height = 0.52
        fountain_top.mesh = top_mesh
        fountain_top.position = Vector3(fx, 1.58, -21.5)
        fountain_top.material_override = gold_material()
        add_child(fountain_top)

    # Glimpse of the royal throne room through the entrance
    _add_box(Vector3(0, 0.22, -34.5), Vector3(8.0, 0.35, 7.0), Color(0.38, 0.23, 0.15))
    _add_box(Vector3(0, 0.45, -36.8), Vector3(4.2, 0.16, 2.8), Color(0.83, 0.59, 0.20))
    _add_box(Vector3(0, 1.25, -37.4), Vector3(2.0, 1.7, 0.75), Color(0.53, 0.12, 0.055))
    _add_box(Vector3(0, 2.2, -37.65), Vector3(2.1, 0.25, 0.95), Color(0.83, 0.59, 0.20))
    _add_box(Vector3(-0.82, 1.95, -37.45), Vector3(0.25, 1.0, 0.7), Color(0.83, 0.59, 0.20))
    _add_box(Vector3(0.82, 1.95, -37.45), Vector3(0.25, 1.0, 0.7), Color(0.83, 0.59, 0.20))
    for side in [-1.0, 1.0]:
        _add_box(Vector3(side * 3.5, 2.2, -36.5), Vector3(0.22, 4.2, 0.22), Color(0.83, 0.59, 0.20))
        _add_box(Vector3(side * 3.5, 4.25, -36.5), Vector3(0.8, 0.18, 0.8), sandstone)

    # Palace balconies, cornices and repeating gold facade bands
    _add_box(Vector3(0, 4.85, -30.45), Vector3(21, 0.28, 1.2), Color(0.83, 0.59, 0.20))
    _add_box(Vector3(0, 5.65, -30.45), Vector3(23, 0.42, 2.0), sandstone)
    _add_box(Vector3(0, 6.0, -30.45), Vector3(21.5, 0.16, 1.7), Color(0.83, 0.59, 0.20))
    for side in [-1.0, 1.0]:
        for j in range(4):
            var balcony_x: float = side * (3.8 + float(j) * 1.65)
            _add_box(Vector3(balcony_x, 3.5, -30.0), Vector3(0.22, 1.0, 0.25), Color(0.83, 0.59, 0.20))
        # Palace corner towers
        _add_box(Vector3(side * 10.0, 5.0, -32.0), Vector3(3.0, 10.0, 3.0), sandstone)
        _add_box(Vector3(side * 10.0, 10.1, -32.0), Vector3(3.8, 0.55, 3.8), Color(0.83, 0.59, 0.20))
        _add_box(Vector3(side * 10.0, 11.0, -32.0), Vector3(2.5, 1.5, 2.5), stone)
        _add_box(Vector3(side * 10.0, 11.9, -32.0), Vector3(3.2, 0.25, 3.2), Color(0.83, 0.59, 0.20))
    # Central royal dome and smaller roof pavilions
    var dome := MeshInstance3D.new()
    var dome_mesh := SphereMesh.new()
    dome_mesh.radius = 3.0
    dome_mesh.height = 3.8
    dome.mesh = dome_mesh
    dome.position = Vector3(0, 8.0, -32.0)
    dome.material_override = _material(Color(0.68, 0.36, 0.16), 0.48, 0.25)
    add_child(dome)
    var finial := MeshInstance3D.new()
    var finial_mesh := CylinderMesh.new()
    finial_mesh.top_radius = 0.04
    finial_mesh.bottom_radius = 0.16
    finial_mesh.height = 1.25
    finial.mesh = finial_mesh
    finial.position = Vector3(0, 10.25, -32.0)
    finial.material_override = gold_material()
    add_child(finial)
    # Royal flags at the palace entrance
    for side in [-1.0, 1.0]:
        _add_box(Vector3(side * 5.6, 7.3, -31.8), Vector3(0.12, 3.0, 0.12), Color(0.30, 0.18, 0.10))
        _add_box(Vector3(side * 5.0, 7.0, -31.8), Vector3(1.1, 1.6, 0.08), Color(0.58, 0.035, 0.045))
    # Low city walls and gatehouse framing the palace district
    _add_box(Vector3(-15.0, 1.4, -24.0), Vector3(1.0, 2.8, 25.0), dark_stone)
    _add_box(Vector3(15.0, 1.4, -24.0), Vector3(1.0, 2.8, 25.0), dark_stone)
    _add_box(Vector3(-15.0, 2.9, -24.0), Vector3(1.4, 0.25, 25.5), sandstone)
    _add_box(Vector3(15.0, 2.9, -24.0), Vector3(1.4, 0.25, 25.5), sandstone)

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
