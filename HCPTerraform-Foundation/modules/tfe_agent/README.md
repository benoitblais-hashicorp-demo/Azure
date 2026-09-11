# HCP Terraform Agent Pool Terraform module

HCP Terraform Agent Pool module which manages configuration and life-cycle 
of your HCP Terraform Agent Pool configuration.

## Permissions

To manage the agent pool resources, provide a user token from an account with 
appropriate permissions. This user should have the `Manage agent pools` permission. 
Alternatively, you can use a token from a team instead of a user token.

## Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in 
order to manage resources.

There are several ways to provide the required token:

- Set the `token` argument in the provider configuration. You can set the token argument in the provider configuration. Use an
input variable for the token.
- Set the `TFE_TOKEN` environment variable. The provider can read the TFE_TOKEN environment variable and the token stored there
to authenticate.

## Features

- Create and manage agent pool.
- Generate and manage agent pool token.

## Usage example
```hcl
module "agent" {
  source            = "./modules/tfe_agent"
  name              = "Agent Name"
  organization      = "Organization Name"
  token_description = ["Token Description"]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.78)

## Providers

The following providers are used by this module:

- <a name="provider_tfe"></a> [tfe](#provider\_tfe) (~> 0.78)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [tfe_agent_pool.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_pool) (resource)
- [tfe_agent_token.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/agent_token) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) Name of the agent pool.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_organization"></a> [organization](#input\_organization)

Description: (Optional) Name of the organization. If omitted, organization must be defined in the provider config.

Type: `string`

Default: `null`

### <a name="input_organization_scoped"></a> [organization\_scoped](#input\_organization\_scoped)

Description: (Optional) Whether or not the agent pool is scoped to all workspaces in the organization.

Type: `bool`

Default: `true`

### <a name="input_token_description"></a> [token\_description](#input\_token\_description)

Description: (Optional) Description of the agent token.

Type: `list(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id)

Description: he ID of the agent pool.

### <a name="output_agent_token"></a> [agent\_token](#output\_agent\_token)

Description: The agent token.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of agent pool.

### <a name="output_organization"></a> [organization](#output\_organization)

Description: The name of the organization associated with the agent pool.
<!-- END_TF_DOCS -->
