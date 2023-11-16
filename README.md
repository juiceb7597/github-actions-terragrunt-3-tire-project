# GitHub Actions Terragrunt 3-tire Project

---

## Terragrunt란?

![terragrunt-logo.png](https://i.esdrop.com/d/f/bPHSKWDXdc/MoGBoGgCLK.png)

- Terraform의 확장으로 Terraform의 기본 기능에 추가적인 기능이 있는 오픈소스 도구이다
- Container를 감싼 것이 Pod이듯이 Terraform을 감싸는 얇은 래퍼(Wrapper)라 불린다
- 각 환경에 대한 구성 파일의 여러 복사본 대신 단일 소스에서 여러 환경에 대한 인프라를 생성하는 데 크게 도움이 된다

## Workflow

![workflow.png](https://i.esdrop.com/d/f/bPHSKWDXdc/gl2SKWQrqv.png)

- `terragrunt init` 명령어을 실행하면 먼저 `terragrunt.hcl`에 정의한 git 저장소를 로컬 시스템에 다운로드한다.

![terragrunt-source.png](https://i.esdrop.com/d/f/bPHSKWDXdc/6NTjbtWT36.png)

- 해당 디렉터리로 이동한 다음 `terraform init` 명령어을 실행한다.
- `terragrunt plan`은 해당 provider로 `terraform plan` 명령어을 실행한다 .
- `terragrunt apply`는 해당 provider로 `terraform apply` 명령어을 실행한다.
- 내부적으로 Terraform 커맨드가 실행되기 때문에 Terragrunt를 얇은 래퍼(Wrapper)라고 부른다.
- Terragrunt 구성 파일인  `terragrunt.hcl`의 hcl은 hashicorp configuration language을 의미하며 Terraform과 동일한 구문을 사용한다

### 기능

- 테라폼 코드를 DRY(Don’t Repeat Yourself)하게 관리할 수 있다.
    - 하나의 테라폼 backend 구성 파일로 환경 전체를 관리할 수 있다.
    
    ![terragrunt-backend.png](https://i.esdrop.com/d/f/bPHSKWDXdc/GF89wMl4Ti.png)
    
    - dev/prod 환경 구성이 각각 폴더에 존재할 경우 S3에 `joo/dev/terraform.tfstate` 과 `joo/prod/terraform.tfstate` 파일이 생긴다.
- 여러 모듈의 Terraform 명령어을 한 번에 실행할 수 있다.
    - `terragrunt.hcl` 파일이 있는 모든 모듈에서 실행된다.
- Auto-init
    - `terragrunt apply` 명령어은 `terragrunt init` 명령어을 자동으로 실행한다

### 도입 사례

- [인프런 Terragrunt 도입기](https://www.youtube.com/watch?v=wpVRc3q1Pc0)

## 아키텍처

![architecture.png](https://i.esdrop.com/d/f/bPHSKWDXdc/moYrbyaqtC.png)

- Dev 환경은 단일 존.
- Prod 환경은 멀티 존.
- 한 번의 Terragrunt 커맨드로 배포한다.

## 파일구조

```jsx
C:.
|
+---.github
|   \---workflows
|           joo-workflow.yml
|
\---joo
    |   terragrunt.hcl
    |
    +---environments
    |   +---dev
    |   |   |   env.hcl
    |   |   |
    |   |   +---db
    |   |   |       db-install.sh
    |   |   |       terragrunt.hcl
    |   |   |
    |   |   +---network
    |   |   |       terragrunt.hcl
    |   |   |
    |   |   +---was
    |   |   |       terragrunt.hcl
    |   |   |       was-install.sh
    |   |   |
    |   |   \---web
    |   |           terragrunt.hcl
    |   |           web-install.sh
    |   |
    |   \---prod
    |       |   env.hcl
    |       |
    |       +---db
    |       |       db-install.sh
    |       |       terragrunt.hcl
    |       |
    |       +---network
    |       |       terragrunt.hcl
    |       |
    |       +---was
    |       |       terragrunt.hcl
    |       |       was-install.sh
    |       |
    |       \---web
    |               terragrunt.hcl
    |               web-install.sh
    |
    \---modules
        +---db
        |       data.tf
        |       main.tf
        |       outputs.tf
        |       variables.tf
        |
        +---network
        |       main.tf
        |       outputs.tf
        |       variables.tf
        |
        +---was
        |       data.tf
        |       main.tf
        |       outputs.tf
        |       variables.tf
        |
        \---web
                data.tf
                main.tf
                outputs.tf
                variables.tf
```

## 테라폼 코드

- Network 모듈
    - VPC
    - 서브넷
    - 라우팅 테이블
    - 인터넷 게이트웨이
    - NAT 게이트웨이

```jsx
# joo/modules/network/main.tf

################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  count = var.create_vpc ? 1 : 0

  cidr_block = var.cidr

  tags = merge(
    { "Name" = "${var.name}-${var.vpc_tags}" }
  )
}

################################################################################
# Publiс Subnets
################################################################################

resource "aws_subnet" "public" {
  count = var.multi_az && var.create_public_subnet ? 2 : var.create_public_subnet && var.create_vpc ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.public_subnet_cidr, count.index)
  tags = merge(
    { "Name" = "${var.name}-${element(var.public_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table" "public" {
  count = var.create_vpc && var.create_public_subnet ? 1 : 0

  vpc_id = aws_vpc.main[0].id
  tags = merge(
    { "Name" = "${var.name}-${element(var.public_route_table_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "public" {
  count = var.multi_az && var.create_public_subnet ? 2 : var.create_public_subnet && var.create_vpc ? 1 : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_public_subnet ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

################################################################################
# WEB Subnets
################################################################################

resource "aws_subnet" "web" {
  count = var.multi_az && var.create_web_subnet ? 2 : var.create_vpc && var.create_web_subnet ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.web_subnet_cidr, count.index)

  tags = merge(
    { "Name" = "${var.name}-${element(var.web_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table" "web" {
  count = var.multi_az && var.create_web_subnet ? 2 : var.create_vpc && var.create_web_subnet ? 1 : 0

  vpc_id = aws_vpc.main[0].id
  tags = merge(
    { "Name" = "${var.name}-${element(var.web_route_table_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "web" {
  count = var.multi_az && var.create_web_subnet ? 2 : var.create_vpc && var.create_web_subnet ? 1 : 0

  subnet_id      = element(aws_subnet.web[*].id, count.index)
  route_table_id = element(aws_route_table.web[*].id, count.index)
}

resource "aws_route" "web_nat_gateway" {
  count = var.multi_az && var.create_public_subnet && var.create_web_subnet && var.create_nat_gateway ? 2 : var.create_public_subnet && var.create_web_subnet && var.create_nat_gateway ? 1 : 0

  route_table_id         = element(aws_route_table.web[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
}

################################################################################
# WAS Subnets
################################################################################

resource "aws_subnet" "was" {
  count = var.multi_az && var.create_was_subnet ? 2 : var.create_vpc && var.create_was_subnet ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.was_subnet_cidr, count.index)

  tags = merge(
    { "Name" = "${var.name}-${element(var.was_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "was" {
  count = var.multi_az && var.create_was_subnet ? 2 : var.create_vpc && var.create_was_subnet ? 1 : 0

  subnet_id      = element(aws_subnet.was[*].id, count.index)
  route_table_id = element(aws_route_table.web[*].id, count.index)
}

################################################################################
# DB Subnets
################################################################################

resource "aws_subnet" "db" {
  count = var.multi_az && var.create_db_subnet ? 2 : var.create_vpc && var.create_db_subnet ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.db_subnet_cidr, count.index)

  tags = merge(
    { "Name" = "${var.name}-${element(var.db_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "db" {
  count = var.multi_az && var.create_db_subnet ? 2 : var.create_vpc && var.create_db_subnet ? 1 : 0

  subnet_id      = element(aws_subnet.db[*].id, count.index)
  route_table_id = element(aws_route_table.web[*].id, count.index)
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.create_public_subnet ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    { "Name" = "${var.name}-${element(var.igw_tags, count.index)}" }
  )
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "nat" {
  count = var.multi_az && var.create_public_subnet && var.create_nat_gateway ? 2 : var.create_public_subnet && var.create_nat_gateway ? 1 : 0

  domain = "vpc"
  tags = merge(
    { "Name" = "${var.name}-${element(var.nat_eip_tags, count.index)}" }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.multi_az && var.create_public_subnet && var.create_nat_gateway ? 2 : var.create_public_subnet && var.create_nat_gateway ? 1 : 0

  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  tags = merge(
    { "Name" = "${var.name}-${element(var.nat_gateway_tags, count.index)}" }
  )

  depends_on = [aws_internet_gateway.this]
}
```

- WEB/WAS/DB 모듈
    - Launch Template
    - 오토스케일링 그룹
    - 보안 그룹

```jsx
# joo/modules/web/main.tf

################################################################################
# Launch template
################################################################################

resource "aws_launch_template" "web" {
  count = var.create_launch_template ? 1 : 0

  name          = "${var.name}-${var.launch_template_name}"
  description   = "${var.name}-${var.launch_template_description}"
  instance_type = var.instance_type
  image_id      = data.aws_ami.amzlinux3.id
  key_name      = var.key_name
  user_data     = var.user_data

  vpc_security_group_ids = aws_security_group.web[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.launch_template_tags}" }
  )
}
################################################################################
# Autoscaling group
################################################################################

resource "aws_autoscaling_group" "this" {
  count = var.create_asg && var.create_launch_template ? 1 : 0

  name = "${var.name}-${var.asg_name}"

  launch_template {
    id = aws_launch_template.web[0].id
  }

  vpc_zone_identifier = var.multi_az && var.create_asg ? var.vpc_zone_identifier : var.create_asg ? [var.vpc_zone_identifier[0]] : []
  min_size            = var.multi_az && var.create_asg ? 2 : var.create_asg ? 1 : 0
  max_size            = var.multi_az && var.create_asg ? 4 : var.create_asg ? 2 : 0
  desired_capacity    = var.multi_az && var.create_asg ? 2 : var.create_asg ? 1 : 0
  # wait_for_elb_capacity     = var.wait_for_elb_capacity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  # target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.asg_tags}"
    propagate_at_launch = true
  }
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "web" {
  count = var.create_launch_template ? 1 : 0

  name        = "${var.name}-${var.web_sg_name}"
  description = "${var.name}-${var.web_sg_description}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.web_sg_ports
    content {
      description = "Allow ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    { "Name" = "${var.name}-${var.sg_tags}" }
  )
}
```

# 4. Terragrunt 코드

- 환경 설정

```jsx
# joo/environments/dev/env.hcl

inputs = {
  multi_az = false
  name     = "dev"
  azs      = ["ap-northeast-2a", "ap-northeast-2c"]
}
```

- Network

```jsx
# joo/environments/dev/network/terragrunt.hcl

terraform {
  source = "../../../modules/network"
}

include "envcommon" {
  path = "../env.hcl"
}

inputs = {

  ################################################################################
  # VPC
  ################################################################################
  create_vpc = true # must be true
  vpc_tags   = "vpc"
  cidr       = "10.0.0.0/16"

  ################################################################################
  # Public Subnets
  ################################################################################
  create_public_subnet    = true
  public_subnet_cidr      = ["10.0.0.0/24", "10.0.10.0/24"]
  public_subnet_tags      = ["ap-northeast-2a-public-subnet", "ap-northeast-2c-public-subnet"]
  public_route_table_tags = ["public-route-table"]

  ################################################################################
  # WEB Subnets
  ################################################################################
  create_web_subnet    = true # must be true
  web_subnet_cidr      = ["10.0.20.0/24", "10.0.30.0/24"]
  web_subnet_tags      = ["ap-northeast-2a-web-subnet", "ap-northeast-2c-web-subnet"]
  web_route_table_tags = ["private-route-table"]

  ################################################################################
  # WAS Subnets
  ################################################################################
  create_was_subnet = true
  was_subnet_cidr   = ["10.0.40.0/24", "10.0.50.0/24"]
  was_subnet_tags   = ["ap-northeast-2a-was-subnet", "ap-northeast-2c-was-subnet"]

  ################################################################################
  # DB Subnets
  ################################################################################
  create_db_subnet = true
  db_subnet_cidr   = ["10.0.60.0/24", "10.0.70.0/24"]
  db_subnet_tags   = ["ap-northeast-2a-db-subnet", "ap-northeast-2c-db-subnet"]

  ################################################################################
  # Internet Gateway
  ################################################################################
  igw_tags = ["igw"]

  ################################################################################
  # NAT Gateway
  ################################################################################
  create_nat_gateway = true # If the condition of create_public_subnet is false, then this will not create NAT Gateway
  nat_eip_tags       = ["ap-northeast-2a-eip", "ap-northeast-2c-eip"]
  nat_gateway_tags   = ["ap-northeast-2a-nat-gateway", "ap-northeast-2c-nat-gateway"]
}
```

- WEB/WAS/DB

```jsx
# joo/environments/dev/web/terragrunt.hcl

terraform {
  source = "../../../modules/web"
}

dependency "network" {
  config_path                             = "../network"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id      = "vpc-mockid"
    web_subnets = ["subnet-mockid1", "subnet-mockid2"]
  }
}

include "envcommon" {
  path = "../env.hcl"
}

inputs = {
  ################################################################################
  # Launch template
  ################################################################################
  create_launch_template      = true
  vpc_zone_identifier         = dependency.network.outputs.web_subnets
  launch_template_name        = "web-launch-template"
  launch_template_description = "web-launch-template"
  instance_type               = "t3.micro"
  key_name                    = "juiceb"
  user_data                   = filebase64("./web-install.sh")
  launch_template_tags        = "launch-template"

  ################################################################################
  # Autoscaling group
  ################################################################################
  create_asg                = true # If the create_launch_template is false, then this will not Autoscaling Group
  asg_name                  = "web-asg"
  asg_tags                  = "web"
  wait_for_capacity_timeout = "5m"
  health_check_type         = "EC2"
  health_check_grace_period = 180

  ################################################################################
  # Security Group
  ################################################################################

  vpc_id             = dependency.network.outputs.vpc_id
  web_sg_name        = "web-sg"
  web_sg_description = "web-sg"
  web_sg_ports = {
    http  = "80"
    https = "443"
  }
  sg_tags = "web-sg"
}
```

- `terragrunt.hcl` 파일에 정의한 변수들은 환경변수로 들어가 Terraform의 변수 값으로 설정된다.
- `dependencies` 블록은 모듈별 종속성을 설정한다. network 모듈의 배포가 선행되고, 생성된 VPC와 Subnet ID의 정보를 구성파일에 입력값으로 전달한다.
    - Dependencies 블록은 `terragrunt run-all` 명령어 사용 시 적용되는 전략이다.
- `mock_outputs`은 종속성 모듈에서 생성될 vpc와 subnet ID를 모의값으로 설정하여 validate, plan 시 오류가 나지 않게 한다.
- `include` 블록은 상위 폴더의 구성파일을 상속할 때 사용한다.

## Workflow 코드

```jsx
# .github/workflow/joo-workflow.yml

name: Terraform AWS Workflow
on:
  pull_request:
    branches: [ main ]
    paths: 
      - './**'
      - '.github/workflows/joo-workflow.yml'
  push:
    branches: [ main ]
    paths: 
      - './**'
      - '.github/workflows/joo-workflow.yml'

jobs:
  tf_code_check: 
    permissions: 
      id-token: write
      contents: read
      pull-requests: write
    env:
      tg_version: 'v0.52.1'
    environment: joo
    defaults:
      run:
        working-directory: ./joo
    runs-on: ubuntu-latest
    steps:
    - name: Checkout tf code in runner environment 
      uses: actions/checkout@v4

    - name: Configure AWS Credentials Action For GitHub Actions
      uses: aws-actions/configure-aws-credentials@v4
      with: 
        role-to-assume: ${{ secrets.AWS_ROLE }}
        aws-region: ap-northeast-2

    - name: Setup Terragrunt
      run: |
        mkdir bin
        wget -O bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/$tg_version/terragrunt_linux_amd64
        chmod +x bin/terragrunt
        echo "$GITHUB_WORKSPACE/joo/bin" >> $GITHUB_PATH

    - name: Terragrunt hclfmt
      id: hclfmt
      run: terragrunt hclfmt --terragrunt-check --terragrunt-diff
      continue-on-error: true

    - name: Terraform fmt
      id: fmt
      run: terraform fmt -check --recursive
      continue-on-error: true

    - name: Terragrunt validate
      id: validate
      run: terragrunt run-all validate --terragrunt-exclude-dir "**/.terragrunt-cache/**/*"

    - name: Terragrunt plan
      id: plan
      run: terragrunt run-all plan --terragrunt-exclude-dir "**/.terragrunt-cache/**/*"

    - name: Terragrunt apply
      id: apply
      if: github.event_name == 'push'
      run: terragrunt run-all apply --terragrunt-exclude-dir "**/.terragrunt-cache/**/*" --terragrunt-non-interactive
```

- Trigger
    - PR 시 `terragrunt plan` 까지만 이루어 진다.
    - Push 시 `terragrunt apply` 까지 이루어 진다.
- AWS Credentials
    - [공식 AWS Credentials Action](https://github.com/marketplace/actions/configure-aws-credentials-action-for-github-actions#overview)에서 권장하는 AWS IAM 자격증명 공급자 엔드포인트와 함께 GitHub의 OIDC 공급자를 사용하였다.
- Terragrunt 명령어
    - `terragrunt hclfmt` 명령어은 `terragrunt.hcl` 구성파일의 스타일과 형식을 맞춰준다.
    - `terragrunt run-all` 명령어은 모든 모듈을 한번에 배포한다.
    - Terragrunt 명령어 실행 시 현재 디렉토리에 `.terragrunt-cache` 폴더를 만들고 관련 구성파일을 가져온다. 이때, 구성파일에 정의된 모듈을 가져온다. 원본 모듈과 가져온 모듈을 중복으로 인식하지 않게  `--terragrunt-exclude-dir "**/.terragrunt-cache/**/*"` 옵션을 준다.

## 느낀 점

- 여러 개의 `terragrunt.hcl` 파일을 사용하다 보니, `terragrunt plan -out` 파일이 하나로 통일되지 않는다. 그러다 보니 `infracost`, `tf-summurize` 같은 테라폼 관련 오픈소스 도구를 사용할 때 불편함이 생겼다. 하나의 `terragrunt.hcl` 파일을 사용하는 것이 좋아보인다.
- Dev/Prod 환경을 한 번의 커맨드로 생성하는 것은 놀라운 경험이었다. 그럼에도 불구하고, 여러 환경의 테라폼 코드를 작성하는 것은 어려운 일이다.
- Terragrunt에서 강조하는 DRY는 쉽게 말하면 반복작업을 하지 말자는 주의인데, 크게 공감하였다. Terraform에서 모듈을 사용할 경우 변수를 child 모듈에도 넣고, 루트 모듈에 넣는다. 그리고 tfvars에서 변수값들을 설정해 주는데, Terragrunt에서는 variables 선언을 모듈에서만 하고,  `terragrunt.hcl` 구성파일에 바로 변수값을 넣어줌으로써 간소화된 절차를 보여준다.