from cairosvg import svg2png
from hashlib import md5
from PIL import Image
from os import walk, listdir
from functools import reduce
from operator import iconcat
from glob import glob
from functools import cmp_to_key

VISUALIZATION_PATH = './visualization/'
BESTS_PATH = VISUALIZATION_PATH + 'bests/'
RESULTS_PATH = VISUALIZATION_PATH + 'results/'


def compare(x, y):
    if len(x) < len(y):
        return -1
    elif len(x) > len(y):
        return 1

    return -1 if x < y else 1


def visualize(individual, name=None, path=None):
    '''Creates .png and .svg files
    '''
    out = '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" version="1.1">'

    for polyline in individual:
        line = ",".join([str(point[0]*0.5)+","+str(point[1]*0.5)
                        for point in polyline['points']])
        out += f'<polyline points="{line}" stroke="{polyline["color"]}" stroke-width="{polyline["width"]}" fill="none" />\n'

    out += '</svg>'

    name = name if name else md5(out.encode()).hexdigest()
    write_to = (path or (VISUALIZATION_PATH + name)) + '.png'

    svg2png(bytestring=out.encode('utf-8'), write_to=write_to)

    f = open((path or (VISUALIZATION_PATH + name)) + '.svg', 'w')
    f.write(out)
    f.close()


def visualize_generation(generation, generate_all=True):
    if generate_all:
        for i, individual in enumerate(generation):
            visualize(individual, str(i + 1))

    # Paths to .png files sorted in ascending order
    paths = sorted(glob(VISUALIZATION_PATH + '/*.png'),
                   key=cmp_to_key(compare))

    imgs = [Image.open(path) for path in paths]

    if len(imgs) > 0:
        imgs[0].save(
            f'{RESULTS_PATH}/result{len(listdir(RESULTS_PATH)) + 1}.gif',
            save_all=True,
            append_images=imgs[1:],
            optimize=False,
            duration=100,
            loop=0
        )


def visualize_best(best):
    filename = BESTS_PATH + 'best' + str(len(listdir(BESTS_PATH)) + 1)
    visualize(best, path=filename)
