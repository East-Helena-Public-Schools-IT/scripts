import json
import csv
import requests
import sys
import os

if __name__ == "__main__":
    xkey = os.environ["XKEY"]
    auxRow = "Hits"
    inputIp = "IP address"

    with open(sys.argv[1], newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        # Collum names of CSV
        print(f'Country Name, ISP, IP, ASN, {auxRow}')
        for row in reader:
            aux=row[auxRow]
            ipaddr=row[inputIp]
            response = requests.get("http://v2.api.iphub.info/ip/" + ipaddr, headers={"X-Key":xkey})
            if (response.status_code == 200):
                # we're chillen
                body = json.loads(response.content)
                # CSV Line
                print(f'{body["countryName"]},{body["isp"]},{body["ip"]},{body["asn"]},{aux}')
            if (response.status_code == 429):
                # too many requests today :_(
                print("Too many requests today (Error 429)")
