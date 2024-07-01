<#
.SYNOPSIS
    Connects to an EC2 instance using AWS Systems Manager (SSM) Session Manager.

.DESCRIPTION
    This script connects to an EC2 instance using AWS Systems Manager (SSM) Session Manager.
    It first retrieves the IP address of the specified hostname and then searches for the instance
    in the specified regions. If the instance is found, it starts an SSM session with the instance.

.PARAMETER hostname
    The hostname of the EC2 instance.

.PARAMETER profile
    The AWS CLI profile to use for authentication. If not specified, the default profile is used.

.NOTES
    - This script requires the AWS CLI to be installed and configured on the machine.
    - The script searches for the instance in the regions specified in the $regions array.
    - If the instance is not found in the default regions, the user is prompted to input a region.

.EXAMPLE
    .\ssm.ps1 my-ec2-instance my-profile
    Connects to the EC2 instance with the hostname my-ec2-instance using the AWS CLI profile my-profile.

.EXAMPLE
    .\ssm.ps1 my-ec2-instance
    Connects to the EC2 instance with the hostname my-ec2-instance using the default AWS CLI profile.

#>

param(
    $hostname,
    [string]$profile
)

$ip = [System.Net.Dns]::GetHostAddresses($hostname) | 
    Where-Object { $_.AddressFamily -eq 'InterNetwork' } | 
    Select-Object -ExpandProperty IPAddressToString

# Initialize $profileArgument as an array
$profileArgument = @()
if ($profile) {
    $profileArgument += "--profile"
    $profileArgument += $profile
}

$awsCommand = "aws"
$regions = @("eu-west-2", "eu-west-1")
$regionFound = $false

foreach ($region in $regions) {
    $arguments = @("ec2", "describe-instances", "--filters", "Name=private-ip-address,Values=$ip", "--region", $region, "--output", "json") + $profileArgument
    $json = & $awsCommand $arguments | ConvertFrom-Json

    if ($json.Reservations.Count -gt 0 -and $json.Reservations[0].Instances.Count -gt 0) {
        $instanceId = $json.Reservations[0].Instances[0].InstanceId
        $regionFound = $true
        break
    }
}

if (-not $regionFound) {
    $region = Read-Host "Unable to find instances in the default regions. Please input a region"
    $arguments = @("ec2", "describe-instances", "--filters", "Name=private-ip-address,Values=$ip", "--region", $region, "--output", "json") + $profileArgument
    $json = & $awsCommand $arguments | ConvertFrom-Json
    $instanceId = $json.Reservations[0].Instances[0].InstanceId
}

if (-not $instanceId) {
    Write-Output "Unable to determine instance ID. Please check the instance details."
} else {
    $arguments = @("ssm", "start-session", "--target", $instanceId, "--region", $region) + $profileArgument
    
    &$awsCommand $arguments
}
