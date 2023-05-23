#!/bin/bash

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "wmscog.com status changed to $statuscode" | sendmail quazmoz@vivaldi.net
    else exit 0
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://goibberifbskjd.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "wmscog.com may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "wmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://goibberifbskjd.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "wmscog.com may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "wmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://goibberifbskjd.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "wmscog.com may be down, please verify" | sendmail quazmoz@vivaldi.net
    else echo "wmscog.com is up"
    fi