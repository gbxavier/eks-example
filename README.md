# Eks Example

This repository has the source code to deploy an EKS cluster using terraform and deploy a simple application written in NodeJS.

## Infrastructure

This section details all the infrastructure pieces that are deployed with this code

### VPC

Find below the VPC(s) created in this project

| VPC Name    | CIDR        | Used? |
| ----------- | ----------- | ----- |
| eks-example | 10.0.0.0/16 | True  |

### Subnets

Find below the subnet(s) created in this project.

| Subnet Name            | CIDR          | Used? |
| ---------------------- | ------------- | ----- |
| eks-public-eu-west-1a  | 10.0.0.0/19   | True  |
| eks-public-eu-west-1b  | 10.0.32.0/19  | True  |
| eks-public-eu-west-1c  | 10.0.64.0/19  | True  |
|                        | 10.0.96.0/19  | False |
| eks-private-eu-west-1a | 10.0.128.0/19 | True  |
| eks-private-eu-west-1b | 10.0.160.0/19 | True  |
| eks-private-eu-west-1c | 10.0.192.0/19 | True  |
|                        | 10.0.224.0/19 | False |
