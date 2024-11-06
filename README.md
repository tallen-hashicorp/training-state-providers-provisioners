# training-state-providers-provisioners

# Terraform State
Terraform is a stateful application. This means that it keeps track of everything you build inside of a state file. You will see the terraform.tfstate and terraform.tfstate.backup files that appear inside your working directory when running Terraform locally. The state file is Terraform's source of record for everything it knows about.

```hcl
{
 "version": 4, # The version of the internal state format used for this state.
 "terraform_version": "1.8.2", # The version of Terraform being used
 "serial": 118, # The version of this particular state file
 "lineage": "451426cd-fae5-5942-47b7-f78a7cfb9160", # Unique identifier for the state file
 "outputs": {}, # If you have any outputs defined
 "resources": [], # If you have any resources being managed
 "check_results": null # If you have any policy checks or preconditions
}
```

## State Storage - Local & Cloud
By default, Terraform stores state locally in a JSON file on disk
```hcl
terraform {
required_providers {
   azurerm = {
     source = "hashicorp/azurerm"
     version = "3.87.0"
   }
   google = {
     source = "hashicorp/google"
     version = "5.11.0"
   }
 }
}
```

```hcl
terraform {
 cloud {
   organization = "danny-hashicorp"
   workspaces {
     name = "nomura-terraform-101"
   }
 }
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = ">=4.60.0"
   }
 }
}
```

## Why sharing state is good…
* Collaborate on values from infrastructure created by other projects
* Separating state isolates the impact of Terraforms actions
* Allows for collaboration across functional teams
* Output values in remote state can be shared in other configurations
* Allows infrastructure to be decomposed into smaller components

## Sharing local state
Reading state from another project can be accomplished with the `terraform.remote_state` data source config depends on the backend but could be a path to a file or the name of an S3 bucket, or the API key to a remote server
```hcl
# Read state from another Terraform config’s state
data "terraform_remote_state" "vpc" {
backend = "local"
config {
  path = "../shared-vpc/terraform.tfstate"
}
}
...
# Elsewhere, use outputs from the state
data.terraform_remote_state.vpc.cidr_block
```

## State Locking
Avoids corrupted Terraform state from concurrent writes. Locking is important as it prevents multiple processes or people running Terraform operations concurrently
* Multiple processes or people could run Terraform operations at the same time resulting in concurrent operations
* Avoids corrupted Terraform state from concurrent writes
* Automatic if supported by the backend
* If state locking fails, the Terraform run will not continue

```
Error: Error locking state: Error acquiring the state lock: resource temporarily unavailable
Lock Info:
 ID:        af5f3bce-b54b-5dda-dad3-9fb2c2614d34
 Path:      terraform.tfstate
 Operation: OperationTypePlan
 Who:       test@Stest.local
 Version:   0.13.5
 Created:   2021-05-11 19:33:16.029636 +0000 UTC
 Info:
Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.
```

## Sensitive Data in State
Committing passwords or sensitive information directly in Terraform code poses a significant security risk, as this data can end up stored in the Terraform state file
* Data Passwords
* User Passwords
* Private Keys

## Terraform State CLI Commands
The Terraform state CLI commands provide functionalities to inspect, manipulate, and manage the state files, enabling actions such as listing resources, pulling the current state, removing resources, and migrating state files between different backends.
* Commands to affect state:
    * list
    * mv
    * show
    * rm

```bash
state-providers-provisioners % terraform state list
data.cloudinit_config.boundary_ingress_worker
data.cloudinit_config.ssh_trusted_ca
data.http.current
aws_instance.boundary_ingress_worker
aws_instance.boundary_public_target
aws_internet_gateway.boundary_ingress_worker_ig
aws_network_interface.boundary_public_target_ni
aws_route_table.boundary_ingress_worker_public_rt
aws_route_table_association.boundary_ingress_worker_public_rt_associate
aws_security_group.boundary_ingress_worker_ssh
aws_security_group.static_target_sg
```

## Import
Terraform has the ability to import state for existing resources
* Not all resources can be imported (consult documentation at https://registry.terraform.io/)
* Before Terraform v1.5.0 resources had to be imported one at a time.
* New import{} block can import more than one resource at a time
* Can see what the proposed import would do before importing

## Import Resources
You may need to import existing resource configuration into Terraform state.

Terraform CLI has commands to assist with this:

```bash
terraform show -json
terraform import aws_instance.example i-001c08da04605c967
terraform show -no-color > compute.tf
```

## Bulk Import
You can add an import block to any Terraform configuration file. A common pattern is to create an imports.tf file, or to place each import block beside the resource block it imports into
```hcl
import {
 to = aws_instance.example
 id = "i-abcd1234"
}

resource "aws_instance" "example" {
 # (other resource arguments...)
}
```

## Terraform Refresh
terraform refresh - command reads the current settings from all managed remote objects and updates the Terraform state to match.
A.K.A `terraform apply -refresh-only -auto-approve`
`terraform apply -refresh-only` only added in v0.15.4 (2021)

## Moved Blocks
Informs Terraform of resource address changes in a configuration without using the CLI
```hcl
resource "aws_instance" "prod_web_compute" {
 ami               = "ami-09ee0944866c73f62"
 instance_type     = "t2.micro"
 availability_zone = "eu-west-2b"
}

moved {
 from = aws_instance.dev_web_compute
 to   = aws_instance.prod_web_compute
}
```

## State in Terraform Enterprise/HCP Terraform
Terraform Enterprise/Cloud stores state remotely for each Workspace
* State versioning
* Managed resource count
* More secure way to share state through tfe_outputs data source
    * Requires authentication for workspace output(s)
Terraform Enterprise/HCP Terraform stores state remotely for each Workspace
* State can contain sensitive data:
    * DB passwords
    * User passwords
    * Private keys
* Consider the state file as sensitive and manage accordingly

# Migrating State to HCP Terraform
* Setting up state remotely in HCP Terraform is very easy
* Adding a cloud {} block you can store state in HCP Terraform
    * Requires using terraform login command to save credentials locally
    * If moving to an existing cloud workspace there cannot be any prior state versions
    * State versions will be saved and are fully searchable ( with the right permissions )
```hcl
terraform {
 cloud {
   organization = "danny-hashicorp"

   workspaces {
     name = "nomura-terraform-101"
   }
 }
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = ">=4.60.0"
   }
 }
}
```

```bash
$ terraform init
Initializing HCP Terraform...
Do you wish to proceed?
 As part of migrating to HCP Terraform, Terraform
 can optionally copy your current workspace state to
 the configured HCP Terraform workspace.
 Answer "yes" to copy the latest state snapshot to the
 configured HCP Terraform workspace.
 Answer "no" to ignore the existing state and just
 activate the configured HCP Terraform workspace with
 its existing state, if any.
 Should Terraform migrate your existing state?
 Enter a value: yes
```

# Providers
* Terraform is logically split into two main parts:
    * Terraform Core
    * Terraform Plugins
* Terraform providers define API interaction
* Provider sourcing and configuration is very flexible

Terraform relies on plugins called providers to interact with cloud providers, SaaS providers, and other APIs. Terraform configurations must declare what providers they require so that Terraform can install and use them

```hcl
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "5.53.0"
   }
 }
}

```

## Multiple Provider Configuration
Sometimes a local provider is developed to extend or change functionality as needed. One needs to distinguish between them to prevent namespace collisions

```hcl
terraform {
 required_providers {
   hashicorp-http = {
     source  = "hashicorp/http"
     version = "~> 2.0"
   }
   mycorp-http = {
     source  = "mycorp/http"
     version = "~> 1.0"
   }
 }
}
```

## Terraform Provider Versions
Versions can be defined using the Semantic Versioning Scheme (SemVer)
```hcl
terraform {
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "5.53.0"
   # version = ">=5.52.2"
   # version = "<=5.53"
   # version = "~>5.53.0"
  }
 }
}
```
## Provider Tiers
| Tier      | Description                                                                                                                                                                                    | Namespace                         |
|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| 🟡 Official  | Official providers are owned and maintained by HashiCorp.                                                                                                                                      | `hashicorp`                       |
| 🔷 Partner   | Partner providers are written, maintained, validated and published by third-party companies against their own APIs. To earn a partner provider badge, the partner must participate in the [HashiCorp Technology Partner Program](https://www.hashicorp.com/partners). | Third-party organization, e.g., `mongodb/mongodbatlas` |
| ⚪ Community | Community providers are published to the Terraform Registry by individual maintainers, groups of maintainers, or other members of the Terraform community.                                     | Maintainer’s individual or organization account, e.g., `DeviaVir/gsuite` |
| ⚫ Archived  | Archived providers are official or partner providers that are no longer maintained by HashiCorp or the community. This may occur if an API is deprecated or interest was low.                  | `hashicorp` or third-party        |

