#! /bin/bash
kcat -b broker:29092 -t customers -f 'key: %k, message: %s\n'

