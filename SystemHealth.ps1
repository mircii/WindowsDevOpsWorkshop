# Team 1 - System Health Monitor
# File: SystemHealth.ps1

# Function 1: Check disk space and warn about full drives
function Check-DiskSpace {
    param(
        [int]$ThresholdPercent = 80
    )
    
    try {
        $drives = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
        $driveResults = @()
        
        foreach ($drive in $drives) {
            $sizeGB = [math]::Round($drive.Size / 1GB, 2)
            $freeGB = [math]::Round($drive.FreeSpace / 1GB, 2)
            $usedPercent = [math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 2)

            if ($usedPercent -gt $ThresholdPercent) {
                $status = "WARNING"
            } else {
                $status = "OK"
            }
            
            $driveInfo = [PSCustomObject]@{
                Drive = $drive.DeviceID
                SizeGB = $sizeGB
                FreeGB = $freeGB
                UsedPercent = $usedPercent
                Status = $status
            }
            
            $driveResults += $driveInfo
        }
        
        return $driveResults
    }
    catch {
        Write-Error "Error accessing drive information: $($_.Exception.Message)"
        return @()
    }
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
