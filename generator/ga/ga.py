import sys
from load_data import load_data
from generator import generate
from visualize import visualize, visualize_generation, visualize_best

if __name__ == '__main__':
    image_path = sys.argv[1]
    use_cache = bool(sys.argv[2])

    data = load_data(image_path, use_cache=use_cache)

    # Initially all polylines are black
    for polyline in data:
        polyline['color'] = 'black'

    best, best_individuals = generate(data, n_generation=20, n_population=10)
    visualize_generation(best_individuals, generate_all=False)
    visualize_best(best)
