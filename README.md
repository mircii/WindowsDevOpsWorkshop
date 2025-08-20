### Function 1: Check-DiskSpace

- **Input:** ThresholdPercent (integer, default 80)
- **Output:** Array of disk objects with properties: Drive, SizeGB, FreeGB, UsedPercent, Status
- **Required:** Use `if/else` to set Status = "WARNING" when UsedPercent > ThresholdPercent, otherwise "OK"
- **Required:** Must work with multiple drives (C:, D:, etc.)

### Function 2: Get-RegistryInfo

- **Input:** KeyPath (string, default Windows version path)
- **Output:** Custom object with properties: WindowsVersion, BuildNumber, RegisteredOwner, InstalledPrograms (array)
- **Required:** Use `while` loop to read at least 5 software registry entries
- **Required:** Handle registry access errors gracefully

### Function 3: Get-SystemInfo

- **Input:** None
- **Output:** Custom object with properties: ComputerName, OSVersion, TotalRAM_GB, CPU_Count, Uptime_Hours, CurrentUser
- **Required:** Calculate uptime in hours from last boot time
- **Required:** Convert memory from bytes to GB (rounded to 2 decimals)
