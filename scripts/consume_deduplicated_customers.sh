#! /bin/bash
kcat -b broker:29092 -t deduplicated_customers -f 'key: %k, message: %s\n'

