from random import *
from math import atan2
import matplotlib
from matplotlib import pyplot as plt

matplotlib.use('QT5Agg')

# Constants
points = [348.5, 278.0, 349.5, 286.0, 349.0, 294.0, 347.5, 302.0, 345.5, 310.0, 343.5, 318.0, 339.0, 325.5, 336.0, 333.5, 332.0, 341.0, 327.5, 349.0, 322.5, 357.0, 317.5, 365.0, 313.5, 373.0, 310.5, 381.0, 315.0,
          391.0, 332.0, 399.0, 344.0, 407.0, 351.0, 414.5, 357.0, 423.0, 360.5, 431.0, 363.5, 439.0, 366.5, 447.5, 368.5, 455.5, 370.5, 463.5, 372.5, 472.0, 375.5, 480.0, 377.0, 488.0, 379.0, 496.5, 381.5, 504.5, 383.5, 512.5]
points = [(points[2 * i], points[2 * i + 1]) for i in range(len(points) // 2)]

n_generation = 10
n_population = 10


def makesvg(lines):
    # Create the svg image
    out = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1">'
    for l in lines:
        l = ",".join([str(p[0]*0.5)+","+str(p[1]*0.5) for p in l])
        out += f'<polyline points="{l}" stroke="black" stroke-width="2" fill="none" />\n'
    out += '</svg>'
    return out


def reproduce(best):
    # Create the population based on the best
    pass


def evaluate(population):
    # Evaluate the population
    # Evaluation criterias are length of the line, the smoothness of the line
    areas = []
    angles = []
    for individual in population:
        points = individual['points']

        # Calculate the area of rectangle where the line sits
        x_min, _ = min(points, key=lambda x: x[0])
        _, y_min = min(points, key=lambda x: x[1])
        x_max, _ = max(points, key=lambda x: x[0])
        _, y_max = max(points, key=lambda x: x[1])

        areas.append((x_max - x_min) * (y_max - y_min))

        # Calculate the sum of angles between all sets of adjacent points
        if len(individual) >= 3:
            angles_sum = 0
            for i in range(len(points) - 2):
                p1, p2, p3 = points[i], points[i +
                                               1], points[i + 2]
                angles_sum += abs(atan2(p3[1] - p1[1], p3[0] - p1[0]) -
                                  atan2(p2[1] - p1[1], p2[0] - p1[0]))
            angles.append(angles_sum)
        else:
            angles.append(1)

        print(x_min, y_min, x_max, y_max)

    max_area, max_angle = max(areas), max(angles)
    return [0.8 * area / max_area + 0.2 * angle / max_angle for area, angle in zip(areas, angles)]


if __name__ == '__main__':
    best = {
        'points': points,
        'stroke_width': 1,
    }
    plt.scatter([p[0] for p in points], [p[1] for p in points])
    plt.show()
    print(evaluate([best]))
    # for i in range(n_generation):
    # population = reproduce(best)
    # scores = evaluate(population)
