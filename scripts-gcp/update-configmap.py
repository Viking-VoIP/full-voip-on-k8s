import re, sys, os
for line in sys.stdin:
    if line == "    }\n":
        print("    }}\n    consul {{\n        errors\n        cache 30\n        forward . {}\n    }}".format(os.environ["CONSUL_DNS_IP"]))
    else:
        print(line[:-1])