import subprocess
import numpy as np
from pprint import pprint
from ast import literal_eval
import os

RUN_LINEDRAW = f'python3 {os.path.abspath(os.getcwd())}/generator/linedraw/linedraw.py -i input/text.png --show-lines --rm-logs'.split()

if __name__ == '__main__':
    # Run linedraw program
    print(RUN_LINEDRAW)
    points_string = subprocess.run(RUN_LINEDRAW
                                   stdout=subprocess.PIPE).stdout.decode('utf-8')
    points = literal_eval(points_string)
    #print(str(points))
    #print(points)
