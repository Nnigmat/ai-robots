extends Spatial

signal pass_data()

export var scale_factor = 1

func _ready():
	var inp = []
	OS.execute('python3', ['/home/nikita/Code/University/Thesis/project/linedraw/linedraw.py', '--show-lines', '--rm-logs','--export-svg'], true, inp)
#	OS.execute('python3', ['../project/main.py'], true, arr)
#	OS.execute('ls', ['-al'], true, arr)
	
	var data = JSON.parse(inp[0]).get_result()['data']
	var res = []
	
	var cos4 = cos(PI / 2)
	var sin4 = sin(PI / 2)
	var canvas_size = get_parent().find_node('Canvas').height
	
	for polyline in data:
		res.append([])
		for point in polyline:
			var new_x = cos4 * point[0] - sin4 * point[1]
			var new_y = sin4 * point[0] + cos4 * point[1]
			res[-1].append(Vector2((new_x + canvas_size) * scale_factor, new_y * scale_factor))

	emit_signal("pass_data", res)
	
