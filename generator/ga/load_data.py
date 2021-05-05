import json
import os
from hashlib import md5
from subprocess import Popen, PIPE
from string import Template

LINEDRAW_COMMAND = Template(
    'python3 ../linedraw/linedraw.py --show-lines --rm-logs -i $input -o output.svg')

CACHES_PATH = Template('./caches/$name')


def load_data(path, use_cache=True):
    '''Send image to linedraw. If the image already processed, it can be just loaded from `caches` folder
    '''
    abs_path = CACHES_PATH.substitute(
        name=md5(path.encode('utf8')).hexdigest())

    if use_cache and os.path.isfile(abs_path):
        return json.loads(open(abs_path).read())['data']

    command = LINEDRAW_COMMAND.substitute(input=path)
    subprocess = Popen(command, shell=True, stdout=PIPE)
    stdout = subprocess.stdout.read()
    data = json.loads(stdout)['data']

    if use_cache:
        f = open(abs_path, 'w')
        f.write(stdout.decode('utf8'))
        f.close()

    return data
