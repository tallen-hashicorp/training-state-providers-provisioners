# Part 3 - State, Providers & Provisioners

# Terraform State
Terraform is a stateful application, which means it keeps track of all resources it manages in a state file. This state file (`terraform.tfstate`) records the exact infrastructure Terraform has created, along with their current configurations. It serves as the single source of truth for Terraform, enabling it to detect changes and maintain the desired state.

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
By default, Terraform stores state locally in a JSON file (`terraform.tfstate`) on disk. However, for collaborative environments, storing the state remotely (e.g., in Terraform Cloud, S3, or other supported backends) is recommended to enable state sharing, locking, and versioning.

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

Example of using Terraform Cloud for state storage:
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

### Benefits of Remote State
* Enables collaboration on infrastructure values across teams.
* Isolates the impact of Terraform actions by separating states.
* Facilitates sharing output values with other configurations.
* Supports decomposing infrastructure into smaller, more manageable components.

## Sharing State Across Configurations
Sharing state from another project can be achieved with the `terraform_remote_state` data source. This approach allows configurations to read outputs from another Terraform state file, enabling modular and scalable architecture.

```hcl
data "terraform_remote_state" "vpc" {
  backend = "local"
  config {
    path = "../shared-vpc/terraform.tfstate"
  }
}

# Example of using remote state data
output "vpc_cidr" {
  value = data.terraform_remote_state.vpc.cidr_block
}
```

## State Locking
Terraform automatically locks state files to prevent corruption from concurrent operations. This feature is essential in collaborative environments to avoid conflicts or unexpected resource changes.

* State locking is automatic if supported by the backend.
* If state locking fails, Terraform will abort the run to prevent issues.

Example error:
```
Error: Error locking state: Error acquiring the state lock: resource temporarily unavailable
Lock Info:
 ID:        af5f3bce-b54b-5dda-dad3-9fb2c2614d34
```

## Sensitive Data in State
Since Terraform state can contain sensitive information (e.g., passwords, private keys), it’s critical to secure it properly. Always use secure backends like Terraform Cloud, AWS S3 with encryption, or Vault to avoid leaking sensitive data.

* Encrypt state files, especially when stored in remote backends.
* Avoid storing secrets directly in Terraform configurations, use Vault or AWS Secrets Manager.

## Terraform State CLI Commands
The Terraform CLI provides several state-related commands that allow you to inspect, modify, and manage state files.

* `list` - Lists all resources in the current state.
* `mv` - Moves a resource to a new address.
* `show` - Shows details of a specific resource in the state.
* `rm` - Removes a resource from the state file without destroying it.

```bash
terraform state list
aws_instance.my_instance
aws_s3_bucket.my_bucket
```

## Importing Existing Resources
Terraform can import existing resources into the state file to start managing them. This is useful for resources created manually or by other tools.

* Import support varies by provider, so check documentation.
* As of v1.5.0, you can use an `import` block for bulk imports.

```hcl
import {
  to = aws_instance.example
  id = "i-abcd1234"
}
```

```bash
terraform import aws_instance.example i-001c08da04605c967
```

## Refreshing State
`terraform refresh` updates the state to match the actual settings of resources. It reads current resource settings from providers and updates the local state.

## Moved Blocks
Terraform's `moved` block allows renaming or moving resources without using CLI commands. It provides a way to modify configurations safely when resource addresses change.

```hcl
moved {
  from = aws_instance.dev_web_compute
  to   = aws_instance.prod_web_compute
}
```

## State in Terraform Enterprise/Cloud (TFE)
TFE securely stores state in remote workspaces, enabling collaboration, state versioning, and secure management of sensitive data.

* Supports state versioning.
* Uses `tfe_outputs` for secure access to workspace outputs.

---

# Providers
Providers are plugins that enable Terraform to interact with different APIs and cloud platforms.

* **Core**: The core is responsible for managing state, executing plans, and interacting with providers.
* **Providers**: Each provider is responsible for managing specific resource types, e.g., AWS, Azure.

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

## Provider Tiers
| Tier      | Description                                                                                                                                                                                    | Namespace                         |
|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| 🟡 Official  | Official providers are owned and maintained by HashiCorp.                                                                                                                                      | `hashicorp`                       |
| 🔷 Partner   | Partner providers are developed and maintained by third-party companies, often as part of the [HashiCorp Technology Partner Program](https://www.hashicorp.com/partners). | Third-party organization, e.g., `mongodb/mongodbatlas` |
| ⚪ Community | Community providers are created by individuals or groups within the Terraform community.                                                               | Maintainer’s account, e.g., `DeviaVir/gsuite` |
| ⚫ Archived  | Providers that are no longer maintained. This could happen due to deprecation or low usage.                                                            | `hashicorp` or third-party        |

## Versioning Providers
Provider versions are specified using semantic versioning, which helps control which provider version is used. Constraints ensure compatibility across Terraform configurations.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.53.0"
    }
  }
}
```

---

## Additional Tips
- **Remote State Backends**: Encourage using remote state backends, like Terraform Cloud or S3, for team projects to ensure state consistency and state-locking.
- **Provider Documentation**: Always refer to provider documentation for specific configuration details, especially with frequently updated APIs.
- **Security Practices**: Avoid storing sensitive data in the configuration files directly. Use secret management tools or dynamic credentials.
- **Terraform Debugging**: Teach students to use the `TF_LOG` environment variable (e.g., `export TF_LOG=DEBUG`) for debugging Terraform issues.