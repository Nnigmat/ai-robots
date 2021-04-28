extends Spatial

signal pass_data()
signal pass_image()

export var scale_factor = 1
export var ON = true

func _ready():
	pass


func _on_Timer_timeout():
	var inp = []
	
	if not ON:
		return 
		
#	OS.execute('python3', [ProjectSettings.globalize_path("res://generator/linedraw/linedraw.py"), '--show-lines', '--rm-logs',  '-i', ProjectSettings.globalize_path('res://generator/input/lenna.png'), '-o', ProjectSettings.globalize_path('res://other/output.svg')], true, inp)
	OS.execute('python3', [ProjectSettings.globalize_path("res://generator/image-to-polyline/image-to-polyline.py"), ProjectSettings.globalize_path('res://generator/input/lenna.png')], true, inp)
	var data = JSON.parse(inp[0]).get_result()['data']
	
	var res = []
#
	var cos4 = cos(PI / 2)
	var sin4 = sin(PI / 2)
	var canvas_size = get_viewport().size.x

	for polyline in data:
		res.append({
			'points': [],
			'width': polyline['width'],
			'color': Color(polyline['color'])
		})
		for i in range(len(polyline['points'])):
			var point = polyline['points'][i]
			var new_x = cos4 * point[0] - sin4 * point[1]
			var new_y = sin4 * point[0] + cos4 * point[1]
			res[-1]['points'].append(Vector2((new_x + canvas_size) * scale_factor, new_y * scale_factor))

	emit_signal("pass_data", res)
	emit_signal("pass_image", 'res://other/output.svg')
