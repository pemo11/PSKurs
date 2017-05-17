<#
 .Synopsis
 Kleine Rechenzentrum-Simulation
 .Notes
 Letzte Aktualisierung: 17/05/2017
#>

# Repräsentiert einen einzelnen Server
class Server
{
  [Int]$Id
  [String]$Name
  [DateTime]$StartTime
  [String]$Status
  [Long]$MemoryGB
  [Byte]$CPUCount
  [String]$ServerOS
  [Double]$CostPerSecond = 0.05

  [void]Start()
  {
    $this.Startzeit = Get-Date
    $this.Status = "Running"
  }

  [void]Stop()
  {
    $this.Status = "Stopped"
  }

  [TimeSpan]GetRunningTime()
  {
    return ((Get-Date) - $this.StartTime)
  }

  [Double]GetCost()
  {
    return $this.GetRunningTime().TotalSeconds * $this.CostPerSecond
  }

}

# Repräsentiert das gesamte Rechenzentrum
class Rechenzentrum
{
    [System.Collections.Generic.List[Server]]$ServerList
    Rechenzentrum([Int]$InitialCount)
    {
        Add-Type -AssemblyName System.Windows.Forms
        $this.Serverliste = New-Object -TypeName System.Collections.Generic.List[Server]
        for($i = 1; $i -le $InitialCount; $i++)
        {
            $ServerNeu = [Server]::new()
            $ServerNeu.Id = $i
            $ServerNeu.MemoryGB = 1
            $ServerNeu.ServerOS = "Windows Server 2012 R2"
            $ServerNeu.CPUCount = 2
            $ServerNeu.Status = "Stopped"
            $this.Serverlist.Add($ServerNeu)
        }
    }

    [Server]AddServer([Int]$MemoryGB, [Int]$CpuCount, [String]$ServerOS)
    {
        $ServerNeu = [Server]::new()
        $ServerNeu.Id = $this.ServerList.Count + 1
        $ServerNeu.MemoryGB = $MemoryGB
        $ServerNeu.CPUCount = $CpuCount
        $ServerNeu.ServerOS = $ServerOS
        return $ServerNeu
    }

    [void]RemoveServer([Int]$Id)
    {
        $ServerRemove = $this.ServerList | Where-Object Id -eq $Id
        if ($ServerRemove -ne $null)
        {
            if([System.Windows.Forms.MessageBox]::Show("Server $Id entfernen?", "From the loop", "YesNo") -eq "Yes")
            {
                $this.ServerList.Remove($ServerRemove)
                Write-Verbose "Server $Id wurde entfernt"
            }
        }
    }
}