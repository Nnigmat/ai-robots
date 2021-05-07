extends Spatial

signal pass_data()
signal pass_image()

export(String, 'Pixel', 'Line art', 'GA') var ART_TYPE = 'Line art'
export var scale_factor = 1
export var ON = true
export var DEFAULT_COLOR = Color('#000')


func _ready():
	pass


func _on_Timer_timeout():
	if not ON:
		return 
		
	var data = _get_data()
	var res = _map_to_canvas(data)

	emit_signal("pass_data", res)
	emit_signal("pass_image", 'res://other/output.svg')

func _instance_color_default(string):
	if not string:
		return DEFAULT_COLOR
		
	return ColorN(string, 1.0)

func _get_data():
	var inp = []
	
	if ART_TYPE == 'Line art':
		OS.execute('python3', [ProjectSettings.globalize_path("res://generator/linedraw/linedraw.py"), '--show-lines', '--rm-logs',  '-i', ProjectSettings.globalize_path('res://generator/input/lenna.png'), '-o', ProjectSettings.globalize_path('res://other/output.svg')], true, inp)
	elif ART_TYPE == 'Pixel':
	#	Width and height of image are passed after the image path
		OS.execute('python3', [ProjectSettings.globalize_path("res://generator/image-to-polyline/image-to-polyline.py"), ProjectSettings.globalize_path('res://generator/input/lenna.png'), 512, 512], true, inp)
	elif ART_TYPE == 'GA':
		var f = File.new()
		f.open('/Users/n-nigmatullin/Code/ai-robots/generator/ga/statistics/2021-05-07_17:10:04.json', File.READ)
		return JSON.parse(f.get_as_text()).get_result()['result']
		
	return JSON.parse(inp[0]).get_result()['data']

func _map_to_canvas(data):
	var res = []
	
	var cos4 = cos(PI / 2)
	var sin4 = sin(PI / 2)
	var canvas_size = get_viewport().size.x
	
	if ART_TYPE == 'Line art' or ART_TYPE == 'GA':
		for polyline in data:
			res.append({
				'points': [],
				'width': polyline['width'],
				'color': _instance_color_default(polyline['color'])
			})
			for i in range(len(polyline['points'])):
				var point = polyline['points'][i]
				var new_x = cos4 * point[0] - sin4 * point[1]
				var new_y = sin4 * point[0] + cos4 * point[1]
				res[-1]['points'].append(Vector2((new_x + canvas_size) * scale_factor, new_y * scale_factor))
	elif ART_TYPE == 'Pixel':
		for polyline in data:
			res.append({
				'points': [],
				'width': polyline['width'],
				'color': _instance_color_default(polyline['color'])
			})
			for i in range(len(polyline['points'])):
				var point = polyline['points'][i]
				var new_x = cos4 * point[0] - sin4 * point[1]
				var new_y = sin4 * point[0] + cos4 * point[1]
				res[-1]['points'].append(Vector2((new_x + canvas_size) * 4 - 2 * canvas_size, new_y * 4))
	return res
