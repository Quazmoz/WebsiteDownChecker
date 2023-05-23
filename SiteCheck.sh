#!/bin/bash

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "Site status changed to $statuscode" | sendmail quazmoz@vivaldi.net
    else exit 0
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://http://goibberifbskjd.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "wmscog.com status changed to $statuscode" | sendmail quazmoz@vivaldi.net
    else exit 0
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "Site status changed to $statuscode" | mail -s "wmscog.com may be down, please verify" "quinn.favo@zionusa.org" -r "STATUS_CHECKER"
    else exit 0
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "Site status changed to $statuscode" | mail -s "wmscog.com may be down, please verify" "quinn.favo@zionusa.org" -r "STATUS_CHECKER"
    else exit 0
    fi