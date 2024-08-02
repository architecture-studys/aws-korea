## 12) CI/CD Module - 충남
### Code List
```shell
├── src
│   ├── templates
│   │   └── index.html
│   ├── appspec.yml
│   ├── buildspec.yaml
│   ├── main.py
│   ├── requirements.txt
│   └── taskdef.json
│
├── 00 provider.tf
├── 00-0 file.tf
├── 01 keypair.tf
├── 02 vpc.tf
├── 03 ec2.tf
├── 04-0 alb-sg.tf
├── 04-1 alb.tf
├── 04-2 alb-tg.tf
├── 05 ecr.tf
├── 06-0 ecr-sg.tf
├── 06-1 ecs-cluster.tf
├── 06-2 ecs-task.tf
├── 06-3 ecs-service.tf
├── 07 codecommit.tf
├── 08 codebuild.tf
├── 09 codedeploy.tf
└── 10 codepipeline.tf
```