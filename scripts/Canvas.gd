extends Spatial

export var width: int = 512
export var height: int = 512
export var line_material: Material = preload("res://materials/line_material.tres")
export var show_lines: bool = true

func _ready():
	# Create the grid of quad meshes
	for i in range(width):
		for j in range(height):
			var mesh_instance = MeshInstance.new()
			var quad_mesh = QuadMesh.new()
			mesh_instance.set_mesh(quad_mesh)
			
			mesh_instance.transform.origin = Vector3(1 + i * 2, 0, 1 + j * 2)
			mesh_instance.scale = Vector3(2, 2, 2)
			mesh_instance.set_rotation(Vector3(-PI / 2, 0, 0))
			add_child(mesh_instance)
		
	if not show_lines:
		return
	
	for i in range(width + 1):
		var mesh_instance = MeshInstance.new()
		var plane_mesh = PlaneMesh.new()
		mesh_instance.set_mesh(plane_mesh)
		mesh_instance.set_material_override(line_material)
		
		mesh_instance.transform.origin = Vector3(i  * 2, 0.01, width)
		mesh_instance.scale = Vector3(0.1, 0.1, height)
		add_child(mesh_instance)

	for i in range(height + 1):
		var mesh_instance = MeshInstance.new()
		var plane_mesh = PlaneMesh.new()
		mesh_instance.set_mesh(plane_mesh)
		mesh_instance.set_material_override(line_material)
				
		mesh_instance.transform.origin = Vector3(height, 0.01, i * 2)
		mesh_instance.scale = Vector3(width, 0.1, 0.1)
		add_child(mesh_instance)
