@tool
extends Node3D

@export var generate: bool = false
@export var seed: int = 1:
	set(value):
		seed = value
		generate = true
@export var size: int = 400:
	set(value):
		size = clamp(value, 0, 1000)
		generate = true
@export var subdivisions: int = 200:
	set(value):
		subdivisions = clamp(value, 0, 200)
		generate = true
@export var height_scale: float = 2.0
@export var world_shader: Material

func _ready():
	generate = true

func _process(delta):
	if generate:
		generate_mesh()
		generate = false
		
func generate_mesh():
	
	for n in get_children():
		remove_child(n)
		n.queue_free() 
	
	var texture = NoiseTexture2D.new()
	texture.noise = FastNoiseLite.new()
	texture.noise.set_seed(seed)
	texture.noise.set_fractal_octaves(6)
	await texture.changed
	var image = texture.get_image()
	var data = image.get_data()
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size= Vector2(size, size)
	plane_mesh.subdivide_depth = subdivisions
	plane_mesh.subdivide_width = subdivisions
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		
		var vx = remap(vertex.x, -size / 2.0, size / 2.0, 0, 511)
		var vz = remap(vertex.z, -size / 2.0, size / 2.0, 0, 511)
		vertex.y = image.get_pixel(vx, vz).r * 30 * height_scale
		
		data_tool.set_vertex(i, vertex)

	array_plane.clear_surfaces()
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_override_material(0, world_shader)
	world_shader.set_shader_parameter("noiseTex", texture)
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	add_child(mesh_instance)
	
