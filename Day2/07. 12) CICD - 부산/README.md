## 12) CI/CD Module 경북
### Code List
```shell
├── src
│   ├── script
│   │   ├── AfterInstall.sh
│   │   ├── ApplicationStart.sh
│   │   ├── ApplicationStop.sh
│   │   └── BeforeInstall.sh
│   ├── src
│   │   └── app.py
│   ├── appspec.yaml
│   ├── buildspec.yaml
│   └── Dockerfile
│
├── 00 provider.tf
├── 00-0 provider.tf
├── 01 vpc.tf
├── 02 ec2.tf
├── 03-0 app-sg.tf
├── 03-1 app-policy.tf
├── 03-2 app-ec2.tf
├── 04 ecr.tf
├── 05 codecommit.tf
├── 06 codebuild.tf
├── 07 codedeploy.tf
└── 08 codepipeline.tf
```