# Team 1 - System Health Monitor
# File: SystemHealth.ps1

# Function 1: Check disk space and warn about full drives
function Check-DiskSpace {
    param(
        [int]$ThresholdPercent = 80
    )

    # Your code here
    # Hint: Use Get-WmiObject Win32_LogicalDisk or Get-CimInstance
    # Calculate percentage used for each drive
    # Use if/else to warn when threshold exceeded
}

# Function 2: Read registry information
function Get-RegistryInfo {
    param(
        [string]$KeyPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"
    )

    # Your code here
    # Hint: Use Get-ItemProperty to read registry values
    # While loop to iterate through multiple software entries
}

# Function 3: Gather system information
function Get-SystemInfo {
    # Your code here
    # Hint: Use Get-ComputerInfo, Get-Process, Get-CimInstance
    # Create a custom object with all system details
}

# Main function that orchestrates everything
function Start-SystemHealthCheck {
    Write-Host "=== System Health Check Starting ===" -ForegroundColor Green

    # Call your functions here in logical order
    # Display results in a nice format

    Write-Host "=== System Health Check Complete ===" -ForegroundColor Green
}

# Export functions for use by megascript
Export-ModuleMember -Function Check-DiskSpace, Get-RegistryInfo, Get-SystemInfo, Start-SystemHealthCheck
