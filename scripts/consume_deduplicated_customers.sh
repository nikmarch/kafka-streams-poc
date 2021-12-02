#! /bin/bash
kcat -b broker:29092 -t deduplicated_customers -e -q -f '- key: %k\n  partition: %p\n' > ./provision/test_cases/output_partitions.yaml

