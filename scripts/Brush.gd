extends Spatial

signal painted()

export(String, "Solid", "Dashed") var stroke_type
export(float, 0, 10, 0.01) var stroke_base_width: float = 3
export(Color, RGB) var stroke_color = Color(0, 0, 0)
export(Mesh) var stroke_shape = PlaneMesh.new()
export(float, 0, 1, 0.01) var stroke_flow: float = 1
export(bool) var signal_painted = true 
	
var timer = 0
var stroke_width = 1
export var is_draw: bool = true
var material = SpatialMaterial.new()

var widths = [6, 8, 10, 12]

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
		var width = widths[stroke_width - 1]
		mesh_instance.scale = Vector3(width, width, width)
#		mesh_instance.get_surface_material(0).albedo_color = stroke_color
		get_parent().get_parent().add_child(mesh_instance)
		
		if signal_painted:
			emit_signal("painted")
	
	timer += delta

func change_brush(color, width):
	if width:
		stroke_width = width
	
	if color:
		material = SpatialMaterial.new()
		material.albedo_color = color
	
func change_brush_size(size):
	if not size:
		return
		
	

func turn_on():
	is_draw = true
	
func turn_off():
	is_draw = false

