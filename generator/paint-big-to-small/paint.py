from typing import List, Tuple, Dict
from PIL import Image
from PIL.ImageFilter import GaussianBlur
from PIL.ImageDraw import Draw
from math import sqrt
from random import shuffle
import numpy as np
import os


def distance_rgb(tuple1: Tuple[int, int, int], tuple2: Tuple[int, int, int]) -> float :
    return sqrt(sum((el1 - el2) ** 2 for el1, el2 in zip(tuple1, tuple2)))


def paint(image: Image, brushes: List[int] = [2, 4, 8, 16, 32], blur_factor: int = 2, threshold: float = 0.05) -> Image:
    width, height = image.size
    canvas = Image.new('RGB', image.size, color=(255, 255, 255))
    draw_canvas = Draw(canvas)

    # Run through each brush size from large to small
    for brush_size in sorted(brushes, reverse=True):
        max_score = 255 * sqrt(3) * (brush_size ** 2)
        size_2 = brush_size // 2
        blurred_image = image.filter(GaussianBlur(blur_factor * brush_size))
        to_brush_positions = []

        # Run through each image with squares of brush_size width
        for x in range(size_2, width - size_2, brush_size):
            for y in range(size_2, height - size_2, brush_size):
                # Calculate the error between points in area
                points_in_area = [(i, j) for i in range(x - size_2, x + size_2) for j in range(y - size_2, y + size_2)]
                distances = [(distance_rgb(canvas.getpixel(point), blurred_image.getpixel(point)), point) for point in points_in_area]

                error = sum(score for score, _ in distances)
                if error > threshold * max_score:
                    _, max_point = max(distances)
                    to_brush_positions.append({'point': max_point, 'color': image.getpixel(max_point)})

        # Paint circles of shuffled brush positions and colors
        shuffle(to_brush_positions)
        for to_paint in to_brush_positions:
            x, y = to_paint['point']
            left_up = (x - size_2, y - size_2)
            right_down = (x + size_2, y + size_2)
            draw_canvas.ellipse([left_up, right_down], fill=to_paint['color'])

    return canvas

def fast_paint(image: Image, brushes: List[int] = [2, 4, 8, 16, 32], blur_factor: int = 2, threshold: int = 100) -> Image:
    width, height = image.size
    canvas = Image.new('RGB', image.size, color=(255, 255, 255))
    draw_canvas = Draw(canvas)
    canvas_data = np.array(canvas)

    # Run through each brush size from large to small
    for brush_size in sorted(brushes, reverse=True):
        size_2 = brush_size // 2
        blurred_image = image.filter(GaussianBlur(blur_factor * brush_size))
        blurred_image_data = np.array(blurred_image)
        to_brush_positions = []

        # Run through each image with squares of brush_size width
        for x in range(size_2, width - size_2, brush_size):
            for y in range(size_2, height - size_2, brush_size):
                canvas_data[x - size_2: x + size_2, y - size_2: y + size_2]
                # Calculate the error between points in area
                points_in_area = [(i, j) for i in range(x - size_2, x + size_2) for j in range(y - size_2, y + size_2)]
                distances = [(distance_rgb(image(point), blurred_image.getpixel(point)), point) for point in points_in_area]

                error = sum(score for score, _ in distances)
                print(error)
                if error > threshold:
                    _, max_point = max(distances)
                    to_brush_positions.append({'point': max_point, 'color': image.getpixel(max_point)})

        # Paint circles of shuffled brush positions and colors
        shuffle(to_brush_positions)
        for to_paint in to_brush_positions:
            x, y = to_paint['point']
            left_up = (x - size_2, y - size_2)
            right_down = (x + size_2, y + size_2)
            draw_canvas.ellipse([left_up, right_down], fill=to_paint['color'])

    return canvas



if __name__ == "__main__":
    image = Image.open('lenna.png')
    res = paint(image, [2, 4, 8, 16, 32, 64], threshold=0.20)
    res.show()