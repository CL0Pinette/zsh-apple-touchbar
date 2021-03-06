#!/usr/bin/python3
import urllib.request as request
import socket
from datetime import datetime
from urllib.error import HTTPError, URLError

"""
Script for getting the relevent info from wttr.io and handling network failures along the way
"""

# Functionality
def is_availabe():
    """Returns True if pinging yielded a response, and False otherwise"""
    status = ping('http://wttr.in/\?format=%d', '')
    if len(status) == 0 or 'Unknown location' in status:
        return False
    else:
        return True

def get_time_of_day():
    """
    Returns either "day", "night", "sunset", or "sunrise" depending on the current time.
    If it couldn't reach wttr.io due to a networking error, returns "?"
    Pings wttr.io for the times of sunrise, sunset, day, and night to do so.
    """
    try:
        times = get_sun_position_times()
    except (HTTPError, URLError, socket.timeout):
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
    """Prints the touchbar string, with each button on a new line"""
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

    body = ping('http://wttr.in/?format=%l|%C+%c|%f|%w|%h', '')

    # Add in emoji
    if len(body) > 0:
        body_parts = body.split('|')

        if len(body_parts) > 0:
            body_parts[0] = '📍 ' + body_parts[0]
        if len(body_parts) > 4:
            body_parts[4] = '💦 ' + body_parts[4]

        body = '\n'.join(body_parts)
        body = '\n' + body

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
    except (URLError, HTTPError, socket.timeout) as error:
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
    request = 'http://wttr.in/\?format=%D|%S|%s|%d'
    result = ping(request)

    times = result.split('|')
    return {
        'dawn': datetime.strptime(times[0], '%H:%M:%S'),
        'sunrise': datetime.strptime(times[1], '%H:%M:%S'),
        'sunset': datetime.strptime(times[2], '%H:%M:%S'),
        'dusk': datetime.strptime(times[3], '%H:%M:%S'),
    }

def time_now():
    """Returns datetime represneting just the time right now (%H:%M:%S, no time zone accounted for)"""
    now = datetime.now()
    now = now.strptime(now.strftime('%H:%M:%S'), '%H:%M:%S')
    return now

# Main
if __name__ == '__main__':
    if is_availabe():
        print(touchbar_string())
    else:
        print("Can't reach wttr ):")
