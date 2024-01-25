import json
import csv
import requests
import sys
import os

if __name__ == "__main__":
    xkey = os.environ["XKEY"]
    with open(sys.argv[1], newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            user=row['User']
            ipaddr=row['IP address']
            response = requests.get("http://v2.api.iphub.info/ip/" + ipaddr, headers={"X-Key":xkey})
            if (response.status_code == 200):
                # we're chillen
                body = json.loads(response.content)
                print(body["countryName"], user, ipaddr)
            if (response.status_code == 429):
                # too many requests today :_(
                print("Too many requests today (Error 429)")
