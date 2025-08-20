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

    try{
        $winInfo = Get-ItemProperty -Path $KeyPath
        $winVersion = $winInfo.ProductName
        $winBuild = $winInfo.CurrentBuild
        $winRegisteredOwner = $winInfo.RegisteredOwner
    }catch {
        Write-Error "Failed to read registry key: $_"
        return
    }

    $swKeyPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    $softwareList = @()

    try {
        $softwareKeys = Get-ChildItem -Path $swKeyPath
        $counter = 0
        $found = 0

        $counter = 0
        $found = 0

        while ($found -lt 5 -and $counter -lt $softwareKeys.Count) {
            $keyPath = $softwareKeys[$counter].PSPath
            $item = Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue

            if ($null -ne $item -and $item.PSObject.Properties.Name -contains "DisplayName") {
                $softwareList += $item.DisplayName
                $found++
            }

            $counter++
        }
    } catch {
        Write-Error "Failed to read installed software: $_"
    }
    return [PSCustomObject]@{
        WindowsVersion = $winVersion
        WindowsBuild = $winBuild
        RegisteredOwner = $winRegisteredOwner
        InstalledSoftware = $softwareList
    }
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