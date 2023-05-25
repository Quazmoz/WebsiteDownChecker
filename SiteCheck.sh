#!/bin/bash

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo -e "Subject:wmscog.com may be down\nPlease verify: https://wmscog.com" | sendmail "qmf1@pitt.edu"
    else echo "wmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://connecticutwmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://connecticutwmscog.com may be down, please verify" | sendmail "qmf1@pitt.edu"
    else echo "https://connecticutwmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://floridawmscog.com)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://floridawmscog.com may be down, please verify" | sendmail "qmf1@pitt.edu"
    else echo "https://floridawmscog.com is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://wmscog.com/wp-admin)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://wmscog.com/wp-admin may be down, please verify" | sendmail "qmf1@pitt.edu"
    else echo "https://wmscog.com/wp-admin is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://newyorkwmscog.com/wp-admin)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://newyorkwmscog.com/wp-admin may be down, please verify" | sendmail "qmf1@pitt.edu"
    else echo "https://newyorkwmscog.com/wp-admin is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://floridawmscog.com/wp-admin)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://floridawmscog.com/wp-admin may be down, please verify" | sendmail "qmf1@pitt.edu"
    else echo "https://floridawmscog.com/wp-admin is up"
    fi

statuscode=$(curl --write-out \\n%{http_code} --silent --head https://connecticutwmscog.com/wp-admin)

    if [[ "$statuscode" -ne 200 ]] ;
    then echo "https://connecticutwmscog.com/wp-admin may be down, please verify" | sendmail "qmf1@pitt.edu"
    else echo "https://connecticutwmscog.com/wp-admin is up"
    fi
