import numpy as np
import os
from PIL import Image
import sys
import json


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

    try:
        IM = Image.open(image_path)
    except IOError:
        print(f'No such file {image_path}')
        sys.exit(1)

    print(json.dumps({
        'data': convert(IM)
    }))
