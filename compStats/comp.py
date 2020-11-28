#!/usr/bin/python3
import os
import subprocess
import concurrent.futures

def run(script):
    """Runs script and returns string of result or empty string if exit code is not 0"""
    try:
        result = subprocess.run([script], capture_output=True)
        return result.stdout.decode('utf-8').strip() if result.returncode == 0 else ''
    except error:
        return '(x) ' + str(error)

def touchbar_string():
    """Prints the touchbar string, with each button on a new line"""
    directory = os.path.dirname(os.path.realpath(__file__))

    with concurrent.futures.ThreadPoolExecutor() as executor:
        files = [
            'battery_label.sh',
            'cpu_label.sh',
            'cpu_load_label.sh',
            'memory_label.sh',
            'io_label.sh',
            'cpu_temp_label.sh'
        ]

        results = executor.map(run, map(lambda f: os.path.join(directory, f), files))
        real_results = list(results)
        real_results = [ s for s in real_results if s != '' ]

        return '\n'.join(real_results)

if __name__ == "__main__":
    print(touchbar_string())
