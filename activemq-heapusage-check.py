#!/usr/bin/python
​
import requests
from requests.auth import HTTPBasicAuth
from requests.exceptions import ConnectionError
import sys
​
try:
    data = requests.get('http://localhost:8161/api/jolokia/read/java.lang:type=Memory/HeapMemoryUsage/used', auth=HTTPBasicAuth('admin', 'admin'))
    data = data.json()
    heapusage = data['value']
except (ConnectionError, NameError):
     with open('/var/log/activemq/activemq.log') as file:
        log_data = file.read()
​
        if 'slave' in log_data:
            print('OK. This Host is in Slave Mode')
            sys.exit(0)
        else:
            print('UNKNOWN')
            sys.exit(3)
​
#print(heapusage)
​
​
if heapusage < 3000000000:
    print('OK. Heap Utilization is at a healthy level ---- {}'.format(heapusage))
    sys.exit(0)
​
elif 3000000000 <= heapusage < 3500000000:
    print("WARNING.  Heap Utilization is approaching 90% Utilizationi ---- {}".format(heapusage))
    sys.exit(1)
​
elif heapusage >= 3500000000:
    print("CRITICAL.  Heap Utilization has exceeded 90% Utilization ---- {}".format(heapusage))
    sys.exit(2)
​
else:
    print('UNKNOWN')
    sys.exit(3)
