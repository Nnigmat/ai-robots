from cairosvg import svg2png
from hashlib import md5
from PIL import Image
from os import walk

VISUALIZATION_PATH = './visualization/'


def visualize(individual, name=None):
    out = '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" version="1.1">'

    for polyline in individual:
        line = ",".join([str(point[0]*0.5)+","+str(point[1]*0.5)
                        for point in polyline['points']])
        out += f'<polyline points="{line}" stroke="{polyline["color"]}" stroke-width="{polyline["width"]}" fill="none" />\n'

    out += '</svg>'

    name = name if name else md5(out.encode()).hexdigest()
    path = VISUALIZATION_PATH + name + '.png'

    svg2png(bytestring=out.encode('utf-8'), write_to=path)

    f = open(VISUALIZATION_PATH + name + '.svg', 'w')
    f.write(out)
    f.close()


def visualize_generation(generation):
    for i, individual in enumerate(generation):
        visualize(individual, str(i))

    paths = sorted(list(walk(VISUALIZATION_PATH))[-1][-1])
    imgs = [Image.open(f'{VISUALIZATION_PATH}/{path}')
            for path in paths if path.endswith('.png')]

    imgs[0].save(f'{VISUALIZATION_PATH}/result.gif', save_all=True,
                 append_images=imgs[1:], optimize=False, duration=100, loop=0)
