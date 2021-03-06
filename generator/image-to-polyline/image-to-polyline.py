import numpy as np
import os
from PIL import Image
import sys
import json
from time import time


def rgb2hex(r, g, b):
    return '#{:02x}{:02x}{:02x}'.format(r, g, b)


def convert(IM):
    res = []
    for i in range(IM.width):
        for j in range(IM.height):
            res.append({
                'points': [[i, j], [i, j]],
                'width': 1,
                'color': rgb2hex(*IM.getpixel((i, j)))
            })

    return res


if __name__ == '__main__':
    image_path = sys.argv[1]
    width = int(sys.argv[2])
    height = int(sys.argv[3])

    try:
        IM = Image.open(image_path)
    except IOError:
        print(f'No such file {image_path}')
        sys.exit(1)

    IM = IM.resize((width, height))

    polylines = convert(IM)

    print(json.dumps({
        'data': polylines
    }))
