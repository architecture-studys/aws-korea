## 14) EKS Observability Module 광주
### Code List
```shell
├── manifest
│   └── cluster.yaml
│
├── src
│   ├── service-a
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── service-b
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   └── service-c
│       ├── app.py
│       ├── Dockerfile
│       └── requirements.txt
│
├── 00 provider.tf
├── 00-0 file.tf
├── 01 keypair.tf
├── 02 vpc.tf
├── 03 bastion.tf
└── 04 ecr.tf
```