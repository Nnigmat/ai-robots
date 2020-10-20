extends Spatial

signal painted()

export(String, "Solid", "Dashed") var stroke_type
export(float, 0, 10, 0.01) var stroke_width: float = 1 
export(Color, RGB) var stroke_color = Color(0, 0, 0)
export(Mesh) var stroke_shape = PlaneMesh.new()
export(float, 0, 1, 0.01) var stroke_flow: float = 1
export(bool) var signal_painted = true 
	
var timer = 0
export var is_draw: bool = true
var material = SpatialMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	material.albedo_color = stroke_color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_draw:
		return
	
	if timer > stroke_flow:
		timer = 0
		var mesh_instance = MeshInstance.new()
		mesh_instance.set_mesh(stroke_shape)
		mesh_instance.set_material_override(material)
		mesh_instance.transform.origin = get_parent().transform.origin
		mesh_instance.scale = Vector3(stroke_width, stroke_width, stroke_width)
#		mesh_instance.get_surface_material(0).albedo_color = stroke_color
		get_parent().get_parent().add_child(mesh_instance)
		
		if signal_painted:
			emit_signal("painted")
	
	timer += delta

func turn_on():
	is_draw = true
	
func turn_off():
	is_draw = false

