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
    [CmdletBinding()]
    param()

    try {
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

    $osName = $os.Caption

    $totalRamGB = [math]::Round([double]$cs.TotalPhysicalMemory / 1GB, 2)

    $cpuCount = [int]$cs.NumberOfLogicalProcessors

    $uptimeHours = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 2)

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
    param(
        [int]$DiskThreshold = 80,
        [string]$RegistryKeyPath = "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"
    )
    
    Write-Host "=== System Health Check Starting ===" -ForegroundColor Green
    Write-Host "Configuration:" -ForegroundColor Cyan
    Write-Host "  - Disk space threshold: $DiskThreshold%" -ForegroundColor Gray
    Write-Host "  - Registry key: $RegistryKeyPath" -ForegroundColor Gray
    Write-Host ""
    
    $overallStatus = "OK"
    $issues = @()
    
    # 1. Check System Information
    Write-Host "1. Gathering System Information..." -ForegroundColor Cyan
    try {
        $systemInfo = Get-SystemInfo
        Write-Host "   Computer Name: $($systemInfo.ComputerName)" -ForegroundColor Green
        Write-Host "   OS Version: $($systemInfo.OSVersion)" -ForegroundColor Green
        Write-Host "   Total RAM: $($systemInfo.TotalRAM_GB) GB" -ForegroundColor Green
        Write-Host "   CPU Count: $($systemInfo.CPU_Count)" -ForegroundColor Green
        Write-Host "   Uptime: $($systemInfo.Uptime_Hours) hours" -ForegroundColor Green
        Write-Host "   Current User: $($systemInfo.CurrentUser)" -ForegroundColor Green
        Write-Host "   Status: OK" -ForegroundColor Green
    }
    catch {
        Write-Host "   Status: ERROR - Failed to gather system info" -ForegroundColor Red
        $overallStatus = "ERROR"
        $issues += "System information gathering failed"
    }
    Write-Host ""
    
    # 2. Check Registry Information
    Write-Host "2. Reading Registry Information..." -ForegroundColor Cyan
    try {
        $registryInfo = Get-RegistryInfo -KeyPath $RegistryKeyPath
        Write-Host "   Windows Version: $($registryInfo.WindowsVersion)" -ForegroundColor Green
        Write-Host "   Windows Build: $($registryInfo.WindowsBuild)" -ForegroundColor Green
        Write-Host "   Registered Owner: $($registryInfo.RegisteredOwner)" -ForegroundColor Green
        Write-Host "   Installed Software (sample):" -ForegroundColor Green
        foreach ($software in $registryInfo.InstalledSoftware) {
            Write-Host "     - $software" -ForegroundColor Gray
        }
        Write-Host "   Status: OK" -ForegroundColor Green
    }
    catch {
        Write-Host "   Status: ERROR - Failed to read registry" -ForegroundColor Red
        $overallStatus = "ERROR"
        $issues += "Registry information reading failed"
    }
    Write-Host ""
    
    # 3. Check Disk Space
    Write-Host "3. Checking Disk Space..." -ForegroundColor Cyan
    try {
        $diskInfo = Check-DiskSpace -ThresholdPercent $DiskThreshold
        $warningCount = 0
        
        foreach ($drive in $diskInfo) {
            $color = switch ($drive.Status) {
                "OK" { "Green" }
                "WARNING" { "Yellow"; $warningCount++ }
                default { "Red" }
            }
            
            Write-Host "   Drive $($drive.Drive): $($drive.UsedPercent)% used ($($drive.FreeGB) GB free of $($drive.SizeGB) GB) - $($drive.Status)" -ForegroundColor $color
        }
        
        if ($warningCount -gt 0) {
            Write-Host "   Status: WARNING - $warningCount drive(s) above threshold" -ForegroundColor Yellow
            if ($overallStatus -eq "OK") { $overallStatus = "WARNING" }
            $issues += "$warningCount drive(s) above space threshold"
        } else {
            Write-Host "   Status: OK - All drives healthy" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "   Status: ERROR - Failed to check disk space" -ForegroundColor Red
        $overallStatus = "ERROR"
        $issues += "Disk space checking failed"
    }
    Write-Host ""
    
    # Display overall summary
    Write-Host "=== HEALTH CHECK SUMMARY ===" -ForegroundColor Cyan
    $summaryColor = switch ($overallStatus) {
        "OK" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
    }
    
    Write-Host "Overall Status: $overallStatus" -ForegroundColor $summaryColor
    
    if ($issues.Count -gt 0) {
        Write-Host "Issues Found:" -ForegroundColor Yellow
        foreach ($issue in $issues) {
            Write-Host "  - $issue" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No issues detected - System is healthy!" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "=== System Health Check Complete ===" -ForegroundColor Green
    
    return [PSCustomObject]@{
        OverallStatus = $overallStatus
        CheckTime = Get-Date
        SystemInfo = $systemInfo
        RegistryInfo = $registryInfo
        DiskInfo = $diskInfo
        Issues = $issues
        IssueCount = $issues.Count
    }
}