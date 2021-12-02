#! /bin/bash
kcat -b broker:29092 -t customers -q -e -f '- key: %k\n  partition: %p\n' > ./provision/test_cases/input_partitions.yaml

