#! /bin/bash
kcat -b broker:29092 -t customers -q -e -f '- key: %k\n  partition: %p\n' > ./tests/input_partitions.yaml

