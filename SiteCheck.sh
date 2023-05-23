#!/bin/bash
subject="mail subject"
body="Hello World"
from="me@example.com"
to="philip.browning@zionusa.org,gabriel.guzman@zionusa.org,quinn.favo@zionusa.org"

#echo -e "Subject:${subject}\n${body}" | sendmail -f "${from}" -t "${to}"

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmsfdgfdgscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo -e "Subject:wmscog.com may be down\nPlease verify: https://wmscog.com" | sendmail "${to}"
    else echo "wmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://connecticutwmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://connecticutwmscog.com may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "https://connecticutwmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://floridawmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://floridawmscog.com may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "https://floridawmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmscog.com/wp-admin)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://wmscog.com/wp-admin may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "https://wmscog.com/wp-admin is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://newyorkwmscog.com/wp-admin)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://newyorkwmscog.com/wp-admin may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "https://newyorkwmscog.com/wp-admin is up"
    fi

: '
statuscode=$(curl --write-out \\n%{http_code} --silent --head https://georgiawmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "wmscog.com may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "wmscog.com is up"
    fi
'