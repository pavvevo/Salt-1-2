extends Node3D

var shader = preload("res://shaders/WorldMaterial.tres")

func _ready():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.fractal_octaves = 6
	#noise.period = 80.0
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size= Vector2(400, 400)
	plane_mesh.subdivide_depth = 200
	plane_mesh.subdivide_width = 200
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_2d(vertex.x, vertex.z) * 30
		
		data_tool.set_vertex(i, vertex)

	array_plane.clear_surfaces()
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_override_material(0, shader)
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	add_child(mesh_instance)
	print("yeaa")
