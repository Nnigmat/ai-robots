extends Spatial

export var width: int = Globals.SIZE
export var height: int = Globals.SIZE
export var line_material: Material = preload("res://materials/line_material.tres")
export var show_lines: bool = true

func _ready():
	assert(width > 0)
	assert(height > 0)
	
	self.scale = Vector3(width, 1, height)
	self.transform.origin = Vector3(height, 1, width)

	if not show_lines:
		return
	
	for i in range(width + 1):
		var mesh_instance = MeshInstance.new()
		var plane_mesh = PlaneMesh.new()
		mesh_instance.set_mesh(plane_mesh)
		mesh_instance.set_material_override(line_material)
		
		mesh_instance.scale = Vector3(0.1 / width, 0.1, 1)
		mesh_instance.transform.origin = Vector3(i / (height / 2.0) - 1, 0.01, 0)
		add_child(mesh_instance)
	
	for i in range(height + 1):
		var mesh_instance = MeshInstance.new()
		var plane_mesh = PlaneMesh.new()
		mesh_instance.set_mesh(plane_mesh)
		mesh_instance.set_material_override(line_material)

		mesh_instance.scale = Vector3(1, 0.1, 0.1 / height)
		mesh_instance.transform.origin = Vector3(0, 0.01, i / (width / 2.0) - 1)
		add_child(mesh_instance)
