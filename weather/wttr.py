import argparse
import concurrent.futures
import time
import urllib.request as request
from datetime import datetime
from urllib.error import HTTPError, URLError

"""
Script for getting the relevent info from wttr.io and handling network failures along the way
"""

# Setup Arguements
parser = argparse.ArgumentParser()
parser.add_argument(
    '--check',
    help='Prints "available" or "unavailable" depending on whether pinging wttr.in gave a valid response',
    action='store_true'
)
parser.add_argument(
    '--time',
    help='Prints "day", "night", "sunset", or "sunrise" depending on time of day',
    action='store_true'
)
parser.add_argument(
    '--info',
    help='Prints "|" delimited string of weather information',
    action='store_true'
)

# Functionality
def check_availibility():
    """Prints available if pinging yielded a response, and unavailable otherwise"""
    status = ping('http://wttr.in/\?format=%d', '')
    if len(status) == 0 or 'Unknown Location' in status:
        print('unavailable')
    else:
        print('available')

def get_time_of_day():
    """
    Returns either "day", "night", "sunset", or "sunrise" depending on the current time.
    If it couldn't reach wttr.io due to a networking error, returns "?"
    Pings wttr.io for the times of sunrise, sunset, day, and night to do so.
    """
    try:
        times = get_sun_position_times()
    except (HTTPError, URLError):
        return '?'

    now = time_now()
    if times['dawn'] < now and now < times['sunrise']:
        return 'sunrise'
    elif times['sunset'] < now and now < times['dusk']:
        return 'sunset'
    elif times['sunrise'] < now and now < times['sunset']:
        return 'day'
    else:
        return 'night'

def touchbar_string():
    """Prints the touchbar string, with each button being delimited by '|'"""
    time_of_day = get_time_of_day()
    if time_of_day == 'day':
        prefix = '🔅'
    elif time_of_day == 'sunrise':
        prefix = '🌅'
    elif time_of_day == 'sunset':
        prefix = '🌆'
    elif time_of_day == 'night':
        prefix = ping('http://wttr.in/?format=%m', '🌙')
    else:
        return ''

    body = ping('http://wttr.in/?format=|%l|%C+%c|%f|%w|%h', '')

    return prefix + body

# Helper Function
def ping(endpoint, default_value=None):
    """
    Returns string of the result of pinging the endpoint, or the default_value if it rose a networking exception.
    If default_value is None, will just raise the exception
    """
    timeout_len = 3
    try:
        res = request.urlopen(endpoint, timeout=timeout_len)
        content = res.read().decode(res.headers.get_content_charset())
        return content
    except (URLError, HTTPError) as error:
        if default_value is not None:
            return default_value
        else:
            raise error


def get_sun_position_times():
    """
    Returns dict of the datetimes of the sunset, sunrise, dawn, and dusk.
    Throws HTTPError or URLError if any 1 url failed to resolve to a value.
    Indexed by the stings "sunset", "sunrise", "dawn", "dusk"
    """
    urls_to_times = {
        'http://wttr.in/\?format="%D"': 'dawn',
        'http://wttr.in/\?format="%S"': 'sunrise',
        'http://wttr.in/\?format="%s"': 'sunset',
        'http://wttr.in/\?format="%d"': 'dusk'
    }
    with concurrent.futures.ThreadPoolExecutor() as executor:
        future_to_times = { executor.submit(ping, url): urls_to_times[url] for url in urls_to_times  }

        time_to_datetimes = {}
        for future in concurrent.futures.as_completed(future_to_times):
            try:
                time_result = datetime.strptime(future.result(), '"%H:%M:%S"')
                time_to_datetimes[future_to_times[future]] = time_result
            except Exception as exc:
                raise exc

        return time_to_datetimes

def time_now():
    """Returns datetime represneting just the time right now (%H:%M:%S, no time zone accounted for)"""
    now = datetime.now()
    now = now.strptime(now.strftime('%H:%M:%S'), '%H:%M:%S')
    return now

# Main
args = parser.parse_args()
if __name__ == '__main__':
    if args.check:
        check_availibility()
    elif args.time:
        print(get_time_of_day())
    elif args.info:
        print(touchbar_string())
    else:
        print('Invalid arguement setup; aborting')
