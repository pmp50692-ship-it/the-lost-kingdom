extends CharacterBody3D

@export var move_speed: float = 5.5
@export var jump_velocity: float = 5.0
var move_input := Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_cooldown := 0.0
var camera_pivot: Node3D
var sword: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var torso: Node3D
var cape: Node3D
var animation_clock := 0.0
var is_attacking := false

func _ready() -> void:
    _build_character()
    _build_camera()

func _mat(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.72
    material.metallic = metallic
    return material

func _part(parent: Node3D, mesh: Mesh, pos: Vector3, material: Material, part_name: String) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.name = part_name
    instance.mesh = mesh
    instance.position = pos
    instance.material_override = material
    parent.add_child(instance)
    return instance

func _capsule(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, part_name: String) -> MeshInstance3D:
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    return _part(parent, mesh, pos, material, part_name)

func _box(parent: Node3D, dimensions: Vector3, pos: Vector3, material: Material, part_name: String) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    return _part(parent, mesh, pos, material, part_name)

func _build_character() -> void:
    var skin := _mat(Color(0.55, 0.31, 0.19))
    var tunic := _mat(Color(0.48, 0.075, 0.035))
    var cloth_light := _mat(Color(0.72, 0.48, 0.20), 0.12)
    var leather := _mat(Color(0.20, 0.075, 0.035))
    var gold := _mat(Color(0.83, 0.58, 0.16), 0.65)
    var steel := _mat(Color(0.72, 0.81, 0.88), 0.8)
    var dark := _mat(Color(0.12, 0.055, 0.035))

    # Layered dhoti and royal warrior silhouette
    _capsule(self, 0.31, 0.78, Vector3(0, 0.73, 0), cloth_light, "Dhoti")
    _box(self, Vector3(0.58, 0.58, 0.10), Vector3(0, 0.66, -0.19), tunic, "Front_Dhoti_Panel")
    _box(self, Vector3(0.58, 0.56, 0.10), Vector3(0, 0.66, 0.19), tunic, "Back_Dhoti_Panel")
    torso = Node3D.new()
    torso.position.y = 1.30
    add_child(torso)
    _capsule(torso, 0.34, 0.88, Vector3(0, 0.05, 0), tunic, "Warrior_Tunic")
    _box(torso, Vector3(0.48, 0.50, 0.09), Vector3(0, 0.07, -0.30), gold, "Chest_Armor")
    _box(torso, Vector3(0.38, 0.39, 0.045), Vector3(0, 0.07, -0.36), tunic, "Chest_Cloth")
    _box(torso, Vector3(0.045, 0.45, 0.025), Vector3(0, 0.06, -0.39), gold, "Armor_Center_Trim")
    _box(torso, Vector3(0.68, 0.12, 0.40), Vector3(0, -0.28, 0), gold, "Waist_Belt")
    _box(torso, Vector3(0.16, 0.24, 0.06), Vector3(0, -0.28, -0.22), leather, "Belt_Buckle")
    _box(torso, Vector3(0.20, 0.48, 0.05), Vector3(0, -0.58, -0.18), cloth_light, "Front_Sash")
    for side in [-1.0, 1.0]:
        _box(torso, Vector3(0.22, 0.52, 0.07), Vector3(side * 0.22, -0.56, -0.16), tunic, "Layered_Skirt")
        _box(torso, Vector3(0.035, 0.46, 0.025), Vector3(side * 0.22, -0.56, -0.205), gold, "Skirt_Gold_Trim")

    # Flowing red cape made from overlapping cloth panels
    cape = Node3D.new()
    cape.position = Vector3(0, 0.28, 0.27)
    torso.add_child(cape)
    for i in range(5):
        var panel := BoxMesh.new()
        panel.size = Vector3(0.19, 1.05 + float(i % 2) * 0.12, 0.045)
        var strip := MeshInstance3D.new()
        strip.mesh = panel
        strip.position = Vector3((float(i) - 2.0) * 0.16, -0.48, 0.05)
        strip.rotation.z = deg_to_rad((float(i) - 2.0) * 5.0)
        strip.material_override = tunic
        cape.add_child(strip)
        var trim := MeshInstance3D.new()
        var trim_mesh := BoxMesh.new()
        trim_mesh.size = Vector3(0.035, 1.02, 0.025)
        trim.mesh = trim_mesh
        trim.position = strip.position + Vector3(0.075, 0, -0.03)
        trim.material_override = gold
        cape.add_child(trim)

    # Head and ancient Indian royal crown
    _capsule(self, 0.22, 0.48, Vector3(0, 1.96, 0), skin, "Head")
    _capsule(self, 0.245, 0.22, Vector3(0, 2.20, 0.015), dark, "Hair")
    _box(self, Vector3(0.48, 0.105, 0.40), Vector3(0, 2.20, 0), gold, "Royal_Crown_Base")
    var crown_body := CylinderMesh.new()
    crown_body.top_radius = 0.075
    crown_body.bottom_radius = 0.235
    crown_body.height = 0.43
    _part(self, crown_body, Vector3(0, 2.45, 0), gold, "Royal_Crown")
    var crown_rim := CylinderMesh.new()
    crown_rim.top_radius = 0.19
    crown_rim.bottom_radius = 0.19
    crown_rim.height = 0.055
    _part(self, crown_rim, Vector3(0, 2.25, 0), cloth_light, "Crown_Rim")
    var crown_tip := SphereMesh.new()
    crown_tip.radius = 0.085
    crown_tip.height = 0.13
    _part(self, crown_tip, Vector3(0, 2.69, 0), gold, "Crown_Finial")
    for side in [-1.0, 1.0]:
        var crown_gem := SphereMesh.new()
        crown_gem.radius = 0.045
        crown_gem.height = 0.07
        _part(self, crown_gem, Vector3(side * 0.14, 2.40, -0.17), steel, "Crown_Side_Gem")
    var jewel := SphereMesh.new()
    jewel.radius = 0.07
    jewel.height = 0.11
    var ruby := _mat(Color(0.72, 0.035, 0.045), 0.18)
    _part(self, jewel, Vector3(0, 2.43, -0.225), ruby, "Crown_Front_Ruby")
    _box(self, Vector3(0.035, 0.16, 0.025), Vector3(0, 2.10, -0.224), ruby, "Royal_Tilak")

    # Royal chest ornaments and layered shoulder armour
    var necklace := TorusMesh.new()
    necklace.inner_radius = 0.105
    necklace.outer_radius = 0.135
    _part(torso, necklace, Vector3(0, 0.37, -0.305), gold, "Royal_Necklace")
    var chest_emblem := SphereMesh.new()
    chest_emblem.radius = 0.085
    chest_emblem.height = 0.12
    _part(torso, chest_emblem, Vector3(0, 0.08, -0.405), ruby, "Royal_Chest_Gem")
    for side in [-1.0, 1.0]:
        var shoulder := SphereMesh.new()
        shoulder.radius = 0.20
        shoulder.height = 0.18
        _part(torso, shoulder, Vector3(side * 0.34, 0.29, 0), gold, "Shoulder_Guard")
        var shoulder_trim := TorusMesh.new()
        shoulder_trim.inner_radius = 0.145
        shoulder_trim.outer_radius = 0.18
        _part(torso, shoulder_trim, Vector3(side * 0.34, 0.29, -0.025), cloth_light, "Shoulder_Trim")
        _box(torso, Vector3(0.055, 0.34, 0.045), Vector3(side * 0.29, -0.02, -0.335), gold, "Chest_Armour_Rivet")

    # Articulated arms
    left_arm = Node3D.new()
    left_arm.position = Vector3(-0.39, 1.56, 0)
    add_child(left_arm)
    _capsule(left_arm, 0.105, 0.57, Vector3(0, -0.27, 0), tunic, "Left_Arm")
    _capsule(left_arm, 0.105, 0.20, Vector3(0, -0.55, 0), leather, "Left_Wrist")
    _box(left_arm, Vector3(0.24, 0.20, 0.22), Vector3(0, -0.48, -0.04), gold, "Left_Bracer")
    _box(left_arm, Vector3(0.255, 0.045, 0.23), Vector3(0, -0.39, -0.045), cloth_light, "Left_Bracer_Edge")
    right_arm = Node3D.new()
    right_arm.position = Vector3(0.39, 1.56, 0)
    add_child(right_arm)
    _capsule(right_arm, 0.105, 0.57, Vector3(0, -0.27, 0), tunic, "Right_Arm")
    _capsule(right_arm, 0.105, 0.20, Vector3(0, -0.55, 0), leather, "Right_Wrist")
    _box(right_arm, Vector3(0.24, 0.20, 0.22), Vector3(0, -0.48, -0.04), gold, "Right_Bracer")
    _box(right_arm, Vector3(0.255, 0.045, 0.23), Vector3(0, -0.39, -0.045), cloth_light, "Right_Bracer_Edge")

    # Legs with leather boots
    left_leg = Node3D.new()
    left_leg.position = Vector3(-0.16, 0.43, 0)
    add_child(left_leg)
    _capsule(left_leg, 0.13, 0.65, Vector3(0, -0.25, 0), cloth_light, "Left_Leg")
    _capsule(left_leg, 0.14, 0.22, Vector3(0, -0.57, -0.045), leather, "Left_Boot")
    right_leg = Node3D.new()
    right_leg.position = Vector3(0.16, 0.43, 0)
    add_child(right_leg)
    _capsule(right_leg, 0.13, 0.65, Vector3(0, -0.25, 0), cloth_light, "Right_Leg")
    _capsule(right_leg, 0.14, 0.22, Vector3(0, -0.57, -0.045), leather, "Right_Boot")

    # Sword attached to the warrior's right hand
    sword = Node3D.new()
    sword.position = Vector3(0, -0.61, -0.03)
    right_arm.add_child(sword)
    _box(sword, Vector3(0.075, 0.78, 0.045), Vector3(0, -0.40, -0.04), steel, "Sword_Blade")
    _box(sword, Vector3(0.27, 0.065, 0.09), Vector3(0, -0.03, -0.04), gold, "Sword_Guard")
    _capsule(sword, 0.055, 0.22, Vector3(0, 0.11, -0.04), leather, "Sword_Grip")

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.38
    shape.height = 2.25
    collision.shape = shape
    collision.position.y = 1.10
    add_child(collision)

func _build_camera() -> void:
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 1.55, 0)
    add_child(camera_pivot)
    # Keep camera yaw independent from the warrior so movement input cannot rotate in circles.
    camera_pivot.top_level = true
    camera_pivot.global_position = global_position + Vector3(0, 1.55, 0)
    var spring := SpringArm3D.new()
    spring.spring_length = 5.5
    spring.margin = 0.2
    camera_pivot.add_child(spring)
    var camera := Camera3D.new()
    camera.rotation_degrees.x = -12
    spring.add_child(camera)
    camera.current = true

func _process(delta: float) -> void:
    animation_clock += delta
    var moving := Vector2(velocity.x, velocity.z).length() > 0.35 and is_on_floor()
    if moving and not is_attacking:
        var swing := sin(animation_clock * 10.0) * 0.48
        left_leg.rotation.x = swing
        right_leg.rotation.x = -swing
        left_arm.rotation.x = -swing * 0.72
        right_arm.rotation.x = swing * 0.72
        torso.position.y = 1.30 + absf(sin(animation_clock * 20.0)) * 0.035
        if is_instance_valid(cape):
            cape.rotation.x = sin(animation_clock * 5.0) * 0.06
            cape.rotation.z = sin(animation_clock * 3.0) * 0.045
    elif not is_attacking:
        left_leg.rotation.x = lerpf(left_leg.rotation.x, 0.0, delta * 8.0)
        right_leg.rotation.x = lerpf(right_leg.rotation.x, 0.0, delta * 8.0)
        left_arm.rotation.x = lerpf(left_arm.rotation.x, 0.0, delta * 8.0)
        right_arm.rotation.x = lerpf(right_arm.rotation.x, 0.0, delta * 8.0)
        torso.position.y = lerpf(torso.position.y, 1.30, delta * 8.0)
        if is_instance_valid(cape):
            cape.rotation.x = lerpf(cape.rotation.x, 0.0, delta * 3.0)
            cape.rotation.z = lerpf(cape.rotation.z, 0.0, delta * 3.0)

func _physics_process(delta: float) -> void:
    if is_instance_valid(camera_pivot):
        camera_pivot.global_position = global_position + Vector3(0, 1.55, 0)
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var input_vector := move_input
    if keyboard.length() > 0.1:
        input_vector = Vector2(keyboard.x, -keyboard.y)
    input_vector = input_vector.limit_length(1.0)

    var forward := -camera_pivot.global_basis.z
    var right := camera_pivot.global_basis.x
    var direction := right * input_vector.x + forward * input_vector.y
    direction.y = 0.0
    direction = direction.normalized()

    if direction.length() > 0.05:
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
        var target_yaw := atan2(-direction.x, -direction.z)
        rotation.y = rotate_toward(rotation.y, target_yaw, 8.0 * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * 5.0 * delta)
    move_and_slide()

func attack() -> void:
    if attack_cooldown > 0.0 or is_attacking:
        return
    attack_cooldown = 0.65
    is_attacking = true
    var tween := create_tween()
    tween.tween_property(right_arm, "rotation:x", -1.05, 0.12)
    tween.parallel().tween_property(sword, "rotation:z", deg_to_rad(75), 0.12)
    tween.tween_property(right_arm, "rotation:x", 0.18, 0.10)
    tween.parallel().tween_property(sword, "rotation:z", deg_to_rad(-30), 0.10)
    tween.tween_property(right_arm, "rotation:x", 0.0, 0.18)
    tween.parallel().tween_property(sword, "rotation:z", 0.0, 0.18)
    tween.finished.connect(func(): is_attacking = false)
