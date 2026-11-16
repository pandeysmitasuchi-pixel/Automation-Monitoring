# Architecture

```text
Browser / User
      |
      | HTTP :80 (HTTPS :443 rule is reserved for future TLS setup)
      v
Internet Gateway
      |
Public subnet 10.0.1.0/24
  +-- Web EC2 (Ubuntu 22.04, public IPv4)
  |     Nginx :80 -> React static build
  |     Nginx /trip,/hello -> Node/Express :3001 (localhost only)
  |     SSH :22 only from learner public IP /32
  +-- NAT Gateway + Elastic IP
             |
             | outbound connections only
             v
Private subnet 10.0.2.0/24
  +-- DB EC2 (Ubuntu 22.04, no public IPv4)
        MongoDB :27017 bound to localhost + private IP
        inbound SSH and MongoDB permitted only from web SG
```

The public route table sends `0.0.0.0/0` to the Internet Gateway. The private route table sends `0.0.0.0/0` to the NAT Gateway. The database server uses NAT for outbound package downloads; the NAT Gateway does not make the database publicly reachable.
