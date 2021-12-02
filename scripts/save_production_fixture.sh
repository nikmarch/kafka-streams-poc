#! /bin/bash
kcat -b broker-40.kafka.ecommerce.dscinfra.com -t dsc.production.rails-site.brain-customer-profile -q -e -o -500 -f '- key: %k\n  partition: %p\n  message: %s\n' > ./provision/test_cases/production_customers.yaml
