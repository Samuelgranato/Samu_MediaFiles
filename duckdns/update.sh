#!/bin/bash
source -
echo url="https://www.duckdns.org/update?domains=$DUCKDNS_SUBDOMAIN&token=$DUCKDNS_API_KEY&ip=&verbose=true" | curl -k -o ~/duckdns/duckdns.log -K -
