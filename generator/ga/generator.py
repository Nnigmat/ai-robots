from copy import deepcopy
from random import choice, random, randint
from collections import Counter
from functools import reduce
from operator import iconcat
from math import sqrt, exp, acos
from multiprocessing import Pool
from visualize import visualize, visualize_best
from statistics import write

LOGS = True

# Available colors
COLORS = ['black', 'yellow', 'green', 'orange']

# Distribution of colors among the polylines
# Currently it is equal distribution
COLORS_DIRSTRIBUTION = [1 / len(COLORS) for i in range(len(COLORS))]

# Radius from point to create new point
POINT_DELTA = 5

# Probability to switch polyline's color
COLOR_SWITCH_PROB = 0.3

# Probability to add/remove point to/from polyline
PIONT_ACTION_PROB = 0.5

# Probability to remove point from polyline
# 1 - POINT_REMOVE_PROB is a probability to add point to polyline
POINT_REMOVE_PROB = 0.5

# Probability to remove point from beggining polyline
# 1 - POINT_REMOVE_BEGGINING_PROB is a probability to remove point from ending polyline
POINT_REMOVE_BEGGINING_PROB = 0.5

# Probability to add point to beggining polyline
# 1 - POINT_ADD_BEGGINING_PROB is a probability to add point to ending polyline
POINT_ADD_BEGGINING_PROB = 0.2

# Probability to modify point
POINT_MODIFY_PROB = 0.5

# Distribution of points among each other
POINTS_DIRSTRIBUTION = 100

# Maximum distribution of points among each other
MAX_POINTS_DISTRIBUTION = 400
MIN_POINTS_DISTRIBUTION = 200

# Desired average length of polyline
POLYLINE_LENGTH = 3000

# Maximum desired average length of polyline
MAX_POLYLINE_LENGTH = 4000
MIN_POLYLINE_LENGTH = 2000

# Distance in both direction where polyline can be shifted
POLYLINE_SHIFT = 10

# Probability to shift the polyline
POLYLINE_SHIFT_PROB = 0.1

# Values for polyline smoothness
POLYLINE_SMOOTHNESS = 150
POLYLINE_SMOOTHNESS_MAX = 180
POLYLINE_SMOOTHNESS_MIN = 0

avg_scores = []


def generate_point(x, y):
    new_x = randint(x - POINT_DELTA, x + POINT_DELTA)
    new_y = randint(y - POINT_DELTA, y + POINT_DELTA)
    return [new_x, new_y]


def distance(point1, point2):
    return sqrt((point1[0] - point1[1]) ** 2 + (point2[0] - point2[1]) ** 2)


def angle_between_3_points(point1, point2, point3):
    a = distance(point1, point2)
    b = distance(point2, point3)
    c = distance(point1, point3)

    if a == 0 or b == 0:
        return 0

    return acos((a ** 2 + b ** 2 - c ** 2) / 2 / a / b)


def score_lens(value, length, max_length, min_length=0):
    if min_length <= value <= length:
        return (value - min_length) / (length - min_length)
    elif length < value <= max_length:
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

        to_shift = random() < POLYLINE_SHIFT_PROB
        shift_x = randint(-POLYLINE_SHIFT,
                          POLYLINE_SHIFT) if to_shift else 0
        shift_y = randint(-POLYLINE_SHIFT,
                          POLYLINE_SHIFT) if to_shift else 0

        for i, point in enumerate(polyline['points']):
            if random() < POINT_MODIFY_PROB:
                x, y = generate_point(*point)
                polyline['points'][i] = [x + shift_x, y + shift_y]

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
            if i == j:
                continue

            dist = distance(point1, point2)
            if dist < minimum:
                minimum = dist

        delta += minimum

    avg_delta = delta / len(points)
    print(f'Average distance between points: {avg_delta}')
    return score_lens(avg_delta, POINTS_DIRSTRIBUTION, MAX_POINTS_DISTRIBUTION, min_length=MIN_POINTS_DISTRIBUTION)


def smoothness_of_polylines(individual):
    smoothness = 0

    for polyline in individual:
        if len(polyline['points']) < 3:
            continue

        prev1 = polyline['points'][0]
        prev2 = polyline['points'][1]

        tmp = 0
        for point in polyline['points'][2:]:
            angle = angle_between_3_points(prev1, prev2, point)
            tmp += 360 - angle if angle > 180 else angle

            prev1 = prev2
            prev2 = point

        # Add average angle of polyline
        smoothness += tmp / (len(polyline['points']) - 2)

    avg_smoothness = smoothness / len(polyline)
    print(f'Average smoothness of polylines: {avg_smoothness}')
    return score_lens(avg_smoothness, POLYLINE_SMOOTHNESS, POLYLINE_SMOOTHNESS_MAX, min_length=POLYLINE_SMOOTHNESS_MIN)


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
    print(f'Average length of polyline: {avg_len}')
    return score_lens(avg_len, POLYLINE_LENGTH, MAX_POLYLINE_LENGTH, min_length=MIN_POLYLINE_LENGTH)


def evaluate(individual):
    return {
        'color': color_distribution_score(individual),
        'points': distances_between_points(individual),
        'polylines': len_polylines(individual),
        'smoothness': smoothness_of_polylines(individual),
    }


def store_global_scores(scores):
    global avg_scores

    tmp = {}
    for score in scores:
        for key, value in score.items():
            if key not in tmp:
                tmp[key] = value
            else:
                tmp[key] += value

    for key, value in tmp.items():
        tmp[key] = value / len(scores)

    avg_scores.append(tmp)


def select_best(population):
    if LOGS:
        print('Evaluation...')

    with Pool(100) as p:
        scores = p.map(evaluate, population)

    store_global_scores(scores)

    total_scores = list(
        map(lambda x: x['color'] + x['points'] + x['polylines'] + x['smoothness'], scores))
    max_score_index = total_scores.index(max(total_scores))
    return population[max_score_index], max(total_scores), scores[max_score_index]


def generate(individual, n_population=2, n_generation=10, logs=True):
    best = individual
    best_individuals = [best]

    global LOGS
    LOGS = logs

    for i in range(n_generation):
        population = generate_population(best, n_population)
        best, score, categories = select_best(population)
        best_individuals.append(best)

        visualize(best, name=str(i + 1))

        if logs:
            print(f'\nGeneration {i + 1}. Best score: {score}.')
            print(f'Color score: {categories["color"]}.')
            print(f'Points distribution score: {categories["points"]}.')
            print(f'Polylines length score: {categories["polylines"]}.')
            print(f'Polylines smoothing score: {categories["smoothness"]}.')

            print('\n')

    write(best, avg_scores, globals())
    return best, best_individuals
