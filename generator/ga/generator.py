from copy import deepcopy
from random import choice, random, randint
from collections import Counter
from functools import reduce
from operator import iconcat
from math import sqrt, exp
from multiprocessing import Pool

LOGS = True

# Available colors
COLORS = ['black', 'yellow', 'green', 'orange']

# Distribution of colors among the polylines
# Currently it is equal distribution
COLORS_DIRSTRIBUTION = [1 / len(COLORS) for i in range(len(COLORS))]

# Radius from point to create new point
POINT_DELTA = 20

# Probability to switch polyline's color
COLOR_SWITCH_PROB = 0.15

# Probability to add/remove point to/from polyline
PIONT_ACTION_PROB = 0.8

# Probability to remove point from polyline
# 1 - POINT_REMOVE_PROB is a probability to add point to polyline
POINT_REMOVE_PROB = 0.1

# Probability to remove point from beggining polyline
# 1 - POINT_REMOVE_BEGGINING_PROB is a probability to remove point from ending polyline
POINT_REMOVE_BEGGINING_PROB = 0.5

# Probability to add point to beggining polyline
# 1 - POINT_ADD_BEGGINING_PROB is a probability to add point to ending polyline
POINT_ADD_BEGGINING_PROB = 0.5

# Probability to modify point
POINT_MODIFY_PROB = 0.6

# Distribution of points among each other
POINTS_DIRSTRIBUTION = 20

# Maximum distribution of points among each other
MAX_POINTS_DISTRIBUTION = 80

# Desired average length of polyline
POLYLINE_LENGTH = 100

# Maximum desired average length of polyline
MAX_POLYLINE_LENGTH = 300


def generate_point(x, y):
    new_x = randint(x - POINT_DELTA, x + POINT_DELTA)
    new_y = randint(y - POINT_DELTA, y + POINT_DELTA)
    return [new_x, new_y]


def distance(point1, point2):
    return sqrt((point1[0] - point1[1]) ** 2 + (point2[0] - point2[1]) ** 2)


def score_lens(value, length, max_length):
    if value <= length:
        return value / length
    elif length < value < max_length:
        return 1 - (value - length) / (max_length - length)

    return 0


def generate_individual(individual):
    '''Generate one individual from the given one.
    It changes the color of the polylines.
    It add/remove points to/from beggining and ending.
    It modify points position.
    '''
    for polyline in individual:
        if random() < COLOR_SWITCH_PROB:
            polyline['color'] = choice(COLORS)

        if len(polyline['points']) == 0:
            continue

        if random() < PIONT_ACTION_PROB:
            if random() < POINT_REMOVE_PROB:
                if random() < POINT_REMOVE_BEGGINING_PROB:
                    polyline['points'].pop(0)
                else:
                    polyline['points'].pop(len(polyline['points']) - 1)

            else:
                if random() < POINT_ADD_BEGGINING_PROB:
                    point = generate_point(*polyline['points'][0])
                    polyline['points'].insert(0, point)
                else:
                    point = generate_point(*polyline['points'][-1])
                    polyline['points'].append(point)

        for i, point in enumerate(polyline['points']):
            if random() < POINT_MODIFY_PROB:
                new_point = generate_point(*point)
                polyline['points'][i] = new_point

    return individual


def generate_population(individual, n_population=10):
    '''Generate population of individuals
    '''
    if LOGS:
        print('Population generation...')

    init_population = [deepcopy(individual)
                       for _ in range(n_population - 1)]
    init_population.append(individual)

    with Pool(100) as p:
        return p.map(generate_individual, init_population)


def color_distribution_score(individual):
    '''Calculate the distribution of polyline colors and compare it to goal
    '''
    counter = Counter(list(map(lambda x: x['color'], individual)))
    distribution = [0 for _ in range(len(COLORS))]
    delta = 0
    total = sum(counter.values())

    for key, value in counter.items():
        distribution[COLORS.index(key)] = value / total

    for (dist1, dist2) in zip(COLORS_DIRSTRIBUTION, distribution):
        delta += abs(dist1 - dist2)

    return 1 - delta / len(COLORS)


def distances_between_points(individual):
    '''Calculate the closest distances between the points and compare it to goal
    '''
    points = reduce(iconcat, list(map(lambda x: x['points'], individual)), [])
    delta = 0

    for i, point1 in enumerate(points):
        minimum = float('inf')
        for j, point2 in enumerate(points):
            dist = distance(point1, point2)
            if dist < minimum:
                minimum = dist

        delta += minimum

    avg_delta = delta / len(points)
    return score_lens(avg_delta, POINTS_DIRSTRIBUTION, MAX_POINTS_DISTRIBUTION)


# def distances_between_polylines(individual):
#     pass


def len_polylines(individual):
    lens = 0

    for polyline in individual:
        if len(polyline['points']) == 0:
            continue

        prev = polyline['points'][0]
        for point in polyline['points'][1:]:
            lens += distance(prev, point)
            prev = point

    avg_len = lens / len(individual)
    return score_lens(avg_len, POLYLINE_LENGTH, MAX_POLYLINE_LENGTH)


def evaluate(individual):
    return color_distribution_score(individual) + distances_between_points(individual) + len_polylines(individual)


def select_best(population):
    if LOGS:
        print('Evaluation...')

    with Pool(100) as p:
        scores = p.map(evaluate, population)

    return population[scores.index(max(scores))], max(scores)


def generate(individual, n_population=2, n_generation=10, logs=True):
    best = individual
    best_individuals = [best]

    global LOGS
    LOGS = logs

    for i in range(n_generation):
        population = generate_population(best, n_population)
        best, score = select_best(population)
        best_individuals.append(best)

        if logs:
            print(f'Generation {i + 1}. Best score: {score}', end='\n\n')

    return best, best_individuals
