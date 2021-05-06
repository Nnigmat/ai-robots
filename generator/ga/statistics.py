from json import dumps
from datetime import datetime
from re import match

STATISTICS_PATH = './statistics/'


def write(individual, statistics, _globals):
    keys = [key for key in _globals.keys() if not key.startswith('_')
            and match(r'^[A-Z_]*$', key)]
    now = datetime.now().strftime('%Y-%m-%d_%H:%M:%S')

    to_write = {
        'result': individual,
        'statistics': statistics,
        'datetime': now,
    }
    for key in keys:
        to_write[key] = _globals.get(key)

    json = dumps(to_write, sort_keys=True, indent=4, ensure_ascii=False)
    with open(STATISTICS_PATH + now + '.json', 'w') as f:
        f.write(json)
