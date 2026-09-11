# Get description Terraform module

The `Get description` module is used to get the description of a sentinel policy.
The description must be located at the top of the file. The description concist of
every commented line from the first line until a blank line.

## Actions

* Read the entire policy file.
* Get the commented and blank line(s).
  * *Commented line must starts with a "#".*
* Find the first blank line in the file.
* Get the line(s) before the blank line.
* Remove the comment symbol ("#") from each line.
* Join line(s) to create a single string.
* Return the description as a string.

## Usage example

```hcl
module "description" {
  source  = "./modules/get_description"
  path    = "./policies/global/allowed-providers.sentinel"
}
```
<!-- BEGIN_TF_DOCS -->
## Required Inputs

The following input variables are required:

### <a name="input_path"></a> [path](#input\_path)

Description: The relative path of the Sentinel policy file that you want to get the description.

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_description"></a> [description](#output\_description)

Description: The description of the Sentinel policy file.
<!-- END_TF_DOCS -->