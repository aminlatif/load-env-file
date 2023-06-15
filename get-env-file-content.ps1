Function getEnvFileContent
{
    param(
        [Parameter(Mandatory = $true)][string]$envFile
    )

    $envHash = @{ }

    if ($DebugPreference -eq 'Continue')
    {
        $debug = "debug"
    }
    if ($debug -eq "debug")
    {
        Write-Host "Loading .env file: $envFile"
    }
    if (Test-Path $envFile)
    {
        if ($debug -eq "debug")
        {
            Write-Host "--------------------"
        }
        $counter = 0
        Get-Content $envFile | ForEach-Object {
            $counter = $counter + 1
            $lineValue = $_ -replace '"|''|`', 'ˈ' -replace '\s+', ' '
            $lineValue = $lineValue -replace '#.*', '' -replace '\s+', ' '
            $lineValueLength = $lineValue.Length
            if ($lineValueLength -gt 0)
            {
                if ($debug -eq "debug")
                {
                    Write-Host "Read Line ${counter}:`t`t $lineValue"
                }
                $lineValueConverted = $lineValue -replace '\${', '${env:'
                if ($debug -eq "debug")
                {
                    Write-Host "Converted Line:`t`t $lineValueConverted"
                }
                $lineValueSubs = $ExecutionContext.InvokeCommand.ExpandString($lineValueConverted)
                if ($debug -eq "debug")
                {
                    Write-Host "Substituted Values:`t $lineValueSubs"
                }
                $name, $value = $lineValueSubs.split('=')
                $refinedValue = $value -replace 'ˈ', ''
                $envHash[$name] = $refinedValue
                if (Test-Path env:\$name) {
                    $currentValue = (Get-Item -Path env:\$name).Value
                    Write-Host "$name already has value:`t`t $currentValue"
                } else {
                    $exportCommand = "set-content env:\$name $value"
                    $exportCommand = $exportCommand -replace 'ˈ', '"'
                    if ($debug -eq "debug") {
                        Write-Host "Export Command:`t`t $exportCommand"
                    }
                    Invoke-Expression $exportCommand
                }
            }
            else
            {
                if ($debug -eq "debug")
                {
                    Write-Host "Skipped empty line $counter."
                }
            }
            if ($debug -eq "debug")
            {
                Write-Host "--------------------"
            }
        }
        Write-Host "$envFile environment variables file loaded."
    }
    else
    {
        Write-Host "$envFile environment variables file not found."
    }

    return $envHash
}
