# inspec-oscal
A proof-of-concept Inspec input plugin that will use an OSCAL component and its schema to configure profile input variables.

## How to Use

 - Install this plugin on your local copy of InSpec: `inspec plugin install <local path to repo>`
 - Provide your OSCAL Component as an Environment Variable before your normal InSpec command: `INSPEC_OSCAL_MODEL_PATH=./path_to_component.json inspec ...`
