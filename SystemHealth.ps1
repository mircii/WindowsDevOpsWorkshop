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
    [CmdletBinding()]
    param()

    try {
        # Informații din WMI (CIM)
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
    }
    catch {
        Write-Host "Error gathering system info: $($_.Exception.Message)" -ForegroundColor Red
        return [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            OSVersion    = "Unknown"
            TotalRAM_GB  = 0
            CPU_Count    = 0
            Uptime_Hours = 0
            CurrentUser  = $env:USERNAME
        }
    }

    # Numele OS din Win32_OperatingSystem.Caption
    $osName = $os.Caption

    # RAM total din bytes -> GB, rotunjit la 2 zecimale
    $totalRamGB = [math]::Round([double]$cs.TotalPhysicalMemory / 1GB, 2)

    # Nr procesoare logice
    $cpuCount = [int]$cs.NumberOfLogicalProcessors

    # Uptime în ore din LastBootUpTime
    $uptimeHours = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 2)

    # Obiectul final, cu propr EXACT cum sunt cerute
    return [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OSVersion    = $osName
        TotalRAM_GB  = $totalRamGB
        CPU_Count    = $cpuCount
        Uptime_Hours = $uptimeHours
        CurrentUser  = $env:USERNAME
    }
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
