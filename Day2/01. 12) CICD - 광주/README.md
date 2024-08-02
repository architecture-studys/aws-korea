## 12) CICD Module - 광주
### Code List
```shell
├── manifest
│   ├── cluster.yaml
│   └── ingress.yaml
│
├── src
│   ├── buildspec.yaml
│   ├── deployment.yaml
│   ├── Dockerfile
│   ├── kustomization.yaml
│   ├── main.py
│   └── requirements.txt
│
├── 00 provider.tf
├── 00-0 file.tf
├── 01 keypair.tf
├── 02 vpc.tf
├── 03 bastion.tf
├── 04 ecr.tf
├── 05 codecommit.tf
├── 06 codebuild.tf
└── 07 cloudtrail.tf
```