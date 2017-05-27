<#
 .Synopsis
 Out-Chart - Ausgabe als Chart
#>

function Out-Chart
{
    [CmdletBinding()]
    param([String]$FilePath,
          [String]$ChartTitle,
          [String]$XAxisTitle,
          [String]$YAxisTitle,
          [Object]$DataSource,
          [String]$XAxisProperty = "Name",
          [String]$Property1,
          [Long]$Property1ScaleFactor = 1000000,
          [String]$Property2,
          [Long]$Property2ScaleFactor = 1000000,
          [String]$Property1Color = "#0000FF",
          [String]$Property2Color = "#FF0000")

    Add-Type -AssemblyName System.Windows.Forms.DataVisualization

    $Chart1 = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart1.Width = 600
    $Chart1.Height = 600
    $Chart1.BackColor = "White"

    [void]$Chart1.Titles.Add($ChartTitle)
    $Chart1.Titles[0].Font = "Arial, 13pt"
    $Chart1.Titles[0].Alignment = "TopLeft"

    $ChartArea = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.ChartArea
    $ChartArea.Name = "ChartArea1"
    $ChartArea.AxisY.Title = $YAxisTitle
    $ChartArea.AxisX.Title = $XAxisTitle
    $ChartArea.AxisY.Interval = 100
    $ChartArea.AxisX.Interval = 1
    $Chart1.ChartAreas.Add($ChartArea)

    $Legend = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Legend
    $Legend.name = "Legend1"
    $Chart1.Legends.Add($Legend)

    [void]$Chart1.Series.Add($Property1)
    $Chart1.Series[$Property1].ChartType = "Column"
    $Chart1.Series[$Property1].BorderWidth  = 3
    $Chart1.Series[$Property1].IsVisibleInLegend = $true
    $Chart1.Series[$Property1].ChartArea = "ChartArea1"
    $Chart1.Series[$Property1].Legend = "Legend1"
    $Chart1.Series[$Property1].Color = $Property1Color
    $DataSource | ForEach-Object {
        [void]$Chart1.Series[$Property1].Points.AddXY($_.$XAxisProperty, ($_.$Property1 / $Property1ScaleFactor))
    }

    if ($PSBoundParameters.ContainsKey("Property2"))
    {
        [void]$chart1.Series.Add($Property2)
        $Chart1.Series[$Property2].ChartType = "Column"
        $Chart1.Series[$Property2].IsVisibleInLegend = $true
        $Chart1.Series[$Property2].BorderWidth  = 3
        $Chart1.Series[$Property2].ChartArea = "ChartArea1"
        $Chart1.Series[$Property2].Legend = "Legend1"
        $Chart1.Series[$Property2].Color = $Property2Color
        $DataSource | ForEach-Object {
            [void]$Chart1.Series[$Property2].Points.AddXY($_.$XAxisProperty, ($_.$Property2 / $Property2ScaleFactor))
        }
    }
    
    $PngPath = Join-Path -Path $PSScriptRoot -ChildPath $FilePath
    $Chart1.SaveImage($PngPath, "png") 
}