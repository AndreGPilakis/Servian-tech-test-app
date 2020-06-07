# Servian TechTestApp
This is Andre's (s3664056) rendition of the Servian Tech test application. It aims to pull the latest release of the application and deploy it to an ec2 instance with a functional database through the use of terraform and ansible.

NOTE TO ASSESORS: Tasks a,b,c,d and e have been completed on the master branch as they are fully complete. The instructions and documents have been completed in the readme on the master branch.

Due to lack of time/knowledge task f and d were hardly completed. There is a very vague attempt on the 'd/hd tasks' branch however it does not work. Because of this there is also little-no documentation on it.
## Dependencies
In order to run this application you will need:
- The latest version of [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- A stable version of [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- The Servian [TechTestApp](https://github.com/servian/techtestapp) - This will be automatically deployed via ansible so there is no need to install this locally.

## Deploy instructions
To Deploy this application:
- Ensure you have configured valid AWS credentials.
- Clone or download this project via github.
- Unzip the project to your desired directory
- cd to the the extracted directory and navigate to the 'infra' folder
- run `$ make up`
    - This will initialise, plan and apply via terraform and then run our ansible playbook to deploy the server and seed the database. Note this will take up to 10 minutes.
- To view the application, navigate to the IP address output from the ansible script on port 80 in a web browser. Alternatively, you may enter the load balancer endpoint given from `terraform output` if you wish.
- NOTE: This configuration will use your default public key stored in .shh/id_rsa.pub . If wish to use a different public key navigate on line 9 of ec2.tf. 

## Cleanup instructions
To tear-down the infastructure: 
- navigate back to the infra folder you ran `$ make up`
- run `$ make down`
    - This will destroy all of the deployed terraform infastructure.

## Problem Analysis
ACME corp. has been gaining increased interest in DevOps after seeing the improvements from the previous work (a1) completed for them. However, Most of their deployments have been done through manually using clickops. There are numerous issues with this namely human error. In order to combat this they have contacted us amazing students to automate the deployment of their application, the [Servian TechTestApp](https://github.com/servian/techtestapp). In order to automate the deployment of this application I will use Terraform scripts to deploy the application to an AWS EC2 instance which is linked to an RDS. The application will then be configured through the use of ansible. All of this will be doable with one CLI input, so that the whole process is automated.

# Assignment tasks

## Task b - create a VPC using Terraform to host the application
This task has been complete in the /infra/vpc.tf file.

First, the vpc is created at the start of the file.
```
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Cervian VPC"
  }
}
```

After this, 9 subnets are made with the following configurations:
Name tag | Availibility Zone | IPv4 CDR block
---------|-------------------|---------------
Cervian_Public1 | us-east-1a | 10.0.0.0/22
Cervian_Public2 | us-east-1b | 10.0.4.0/22
Cervian_Public3 | us-east-1c | 10.0.8.0/22
Cervian_Private1 | us-east-1a | 10.0.16.0/22
Cervian_Private2 | us-east-1b | 10.0.20.0/22
Cervian_Private3 | us-east-1c | 10.0.24.0/22
Cervian_Data1 | us-east-1a | 10.0.32.0/22
Cervian_Data2 | us-east-1b | 10.0.36.0/22
Cervian_Data3 | us-east-1c | 10.0.40.0/22

An example of one of the subnets is as follows:
```
resource "aws_subnet" "Cervian_public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Public1"
  }
}
```

The subnets have been created in this way so that there is 3 layers across 3 availibility zones. (Public, Private and Data.)

## task c - Create 3 layer application infastructure using Terraform

### Creating a load balancer in the public layer
First, a target group is creaded for the loadbalancer inside ec2.tf:
```
resource "aws_lb_target_group" "tech_test_app" {
  name     = "tech-test-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
```
 
Next we create the actual Load balancer for the application, also within ec2.tf.
```
resource "aws_lb" "tech_test_app" {
  name               = "tech-test-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.Cervian_public1.id, aws_subnet.Cervian_public2.id, aws_subnet.Cervian_public3.id]
}
```
This will ensure the load of the application is distubuted amongs the 3 public subnets we created earlier.
Finally, we create the load balancer listener. This defines our routing and ties the port and protocol to the instances in the target group.
```
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.tech_test_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tech_test_app.arn
  }
}
```

### Create an EC2 instance in the private layer

Firstly we create an EC2 instance within the ec2.tf file.
```
resource "aws_instance" "web" {

  ami             = var.ami_id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.Cervian_private1.id
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_http_ssh.id]

  tags = {
    Name = "Tech test App"
  }
}
```
This creates our EC2 instance with the specified ami (currently the most recent amazon AMI). We also attatch it to the private subnet to keep it deployed in the private layer.

The key pairs referenced in the EC2 instance are also created in ec2.tf:
```
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  #Change your public key here if it is named differently.
  public_key = file("~/.ssh/id_rsa.pub")
}
```
This will get the public key from the users .ssh directory assuming it is named id_rsa.pub. If not, it will need to be changed.

We also create a security group "allow_http_ssh" - This is a security group that will allow ingress/egress on ports 22 and 80 so that the instance is able to communicate on these ports. Please view the object in ec2.tf for full code.

### Create a Database deployed in the Data Layer
In order to deploy the database to the database layer, a subnet group is created:
```
resource "aws_db_subnet_group" "data_subnet_group" {
  name       = "data_subnet_group"
  subnet_ids = [aws_subnet.Cervian_data1.id, aws_subnet.Cervian_data2.id, aws_subnet.Cervian_data3.id]

  tags = {
    Name = "My DB subnet group"
  }
}
```
This lists all out data subnets onto one subnet group.
Next, the DB instance is created in db.tf:
```
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6.16"
  instance_class       = "db.t2.micro"
  name                 = "app"
  username             = "postgres"
  password             = "mysupersecretpassword"
  skip_final_snapshot  = true
  port                 = 5432
  db_subnet_group_name = aws_db_subnet_group.data_subnet_group.name
  vpc_security_group_ids = [aws_security_group.allow_postgres.id, aws_security_group.allow_http_ssh]
}
```
This allows us to create the database with all of the credential we want, and also attatch the security group and previously made subnet group. An additional Security group "allow_postgres" is created, which allows the DB to communicate on port 5432.

## Automate deployment of the application with ansible
All of the code for this task is located is the 'ansible' directory.
### Automatically generating the inventory file:
The inventory file is generated right before running the ansible playbook in the 'run_ansible.sh' shell script as follows:
```
echo "all:" > inventory.yml 
echo "  hosts:" >> inventory.yml 
echo "    \"$(cd ../infra && terraform output instance_public_ip)\"" >> inventory.yml
```
All this does is get the instance ip from terraform output and echo it along with the other basic inventory file structure code.

### Download the application and copy it to the local drive
This is done within our ansible playbook, which is automatically run at the end of our run_ansible script.
```
    - name: Create app directory
      become: yes
      file:
        path: "{{ app_directory }}"
        state: directory
        mode: '0755'
    #downloads the file.
    - name: Download and unzip file
      become: yes
      unarchive:
        src: https://github.com/servian/TechTestApp/releases/download/v.0.6.0/TechTestApp_v.0.6.0_linux64.zip
        dest: "{{ app_directory }}"
        remote_src: yes
```
We first create a directory on our ec2 Instance with the correct permissions, then download and unzip it using the unarchive command. The app_directory varriable is declared earlier in the playbook, currently set to /etc/tech-test-app.

### Configure the application with correct credentials.

Firstly, we must pass in all of the credentials we want. This is done by using the --extra vars parameter when running our ansible playbook. These varriables are all gathered from terraform output of our infastructure. An example of one of this varriable being passed is as follows:
`--extra-vars "db_endpoint=$(cd ../infra && terraform output db_endpoint)`
Once we have all of the credentials we want, we use move a copy of the config file temple (located at /ansible/templates/conf.toml.tpl) to the server, with the relevant variables : 
```
    - name: Update config file
      become: yes
      vars:
        db_user: "{{ db_user }}"
        db_password: "{{ db_pass }}"
        db_name: app
        db_port: 5432
        trimmed_db_endpoint: "{{db_endpoint | replace(':5432','')}}"
        listen_host: "0.0.0.0"
        listen_port: 80
      template:
        dest: "{{ app_directory }}/dist/conf.toml"
        src: templates/config.toml.tpl
```
Once these have been copied to the server we are ready to launch the application.

### Set up the application as a service using SystemD to automatically start

In a similar fassion to the previous step, we begin by copying our service template onto the server. (the template can be found at ansible/templates/startServer.service.tpl)
```
    - name: Transfer Server start template
      become: yes
      template:
        dest: /usr/lib/systemd/system/startServer.service
        src: templates/startServer.service.tpl
```
Once the service has been transfered onto the server, we run another ansible command to get the service running.
```
    - name: Ensure service is enabled
      become: yes
      service:
        name: startServer.service
        state: started
        enabled: yes
```
This will ensure that the startServer service is always running when the ec2 instance is up.

## Task e -  Automate database deployment to the database instance

This is rather simple as we have already deployed the database with terraform in the db.tf file.
All that is left now to do is seed the database, whch is done with the updatedb command. This is how it looks in our ansible playbook :
```
    - name: Seed database
      become: yes
      command: ./TechTestApp updatedb -s
      args:
        chdir: "{{ app_directory }}/dist"
```
Do note the -s flag. If you do not have the -s flag here it will ruin the databse as it will drop the tables and attempt to re-create them which we do not have the permissions for. the-s flag MUST be used. see [issue #29](https://github.com/servian/TechTestApp/issues/29) for more info.

## Task F and G
See d/hd task branch for what was attempted.
