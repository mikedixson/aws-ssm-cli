# aws-ssm-cli

#### SYNOPSIS
    Connects to an EC2 instance using AWS Systems Manager (SSM) Session Manager by hostname.

#### DESCRIPTION
    This script connects to an EC2 instance using AWS Systems Manager (SSM) Session Manager.
    It first retrieves the IP address of the specified hostname and then searches for the instance
    in the specified regions. If the instance is found, it starts an SSM session with the instance.

#### PARAMETER hostname
    The hostname of the EC2 instance.

#### PARAMETER profile
    The AWS CLI profile to use for authentication. If not specified, the default profile is used.

#### NOTES
    - This script requires the AWS CLI to be installed and configured on the machine.
    - The script searches for the instance in the regions specified in the $regions array.
    - If the instance is not found in the default regions, the user is prompted to input a region.

#### EXAMPLE with Named Profile
    .\ssm.ps1 my-ec2-instance my-profile
    Connects to the EC2 instance with the hostname my-ec2-instance using the AWS CLI profile my-profile.
    This can be used with SSO Profile names too.

#### EXAMPLE
    .\ssm.ps1 my-ec2-instance
    Connects to the EC2 instance with the hostname my-ec2-instance using the default AWS CLI profile.
