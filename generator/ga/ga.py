import sys
from load_data import load_data
from generator import generate

if __name__ == '__main__':
    image_path = sys.argv[1]
    use_cache = bool(sys.argv[2])

    data = load_data(image_path, use_cache=use_cache)
    generate(data)
