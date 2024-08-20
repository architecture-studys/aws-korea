## Terraform Data Sample
### VPC
```
data "aws_vpc" "main" {
  id = <VPC ID>
}
```

<br>

### Subnet
```
data "aws_subnet" "public_a" {
  id = <Subnet ID>
}
```

<br>

### keypair
```
data "aws_key_pair" "example" {
  key_name = "<Keypair Name>"
}
```

<br>

### IAM Role
```
data "aws_iam_role" "example" {
  name = "<Role Name>"
}
```