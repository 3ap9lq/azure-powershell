﻿<#
.SYNOPSIS
Tests PowerBI Embedded Capacity lifecycle (Create, Update, Get, List, Delete).
#>
function Test-CleanCapacity
{
	try
	{  
		# Creating capacity
		$RGlocation = Get-RG-Location
		$location = Get-Location
		$resourceGroupName = Get-ResourceGroupName
		$capacityName = Get-PowerBIEmbeddedCapacityName
	}
	finally
	{
		# cleanup the resource group that was used in case it still exists. This is a best effort task, we ignore failures here.
		Invoke-HandledCmdlet -Command {Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -ErrorAction SilentlyContinue} -IgnoreFailures
		Invoke-HandledCmdlet -Command {Remove-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue} -IgnoreFailures
	}
}

<#
.SYNOPSIS
Tests PowerBI Embedded Capacity lifecycle (Create, Update, Get, List, Delete).
#>
function Test-CreateCapacity
{
	# Creating capacity
	$RGlocation = Get-RG-Location
	$location = Get-Location
	$resourceGroupName = Get-ResourceGroupName
	$capacityName = Get-PowerBIEmbeddedCapacityName

	New-AzureRmResourceGroup -Name "TestRG" -Location "West US"
		
#	$capacityCreated = New-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Location $location -Sku 'A1' -Administrator 'aztest0@stabletest.ccsctp.net','aztest1@stabletest.ccsctp.net'
    
#	Assert-AreEqual $capacityName $capacityCreated.Name
#	Assert-AreEqual $location $capacityCreated.Location
#	Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityCreated.Type
#	Assert-AreEqual 2 $capacityCreated.Administrators.Count
#	Assert-True {$capacityCreated.Id -like "*$resourceGroupName*"}
}

<#
.SYNOPSIS
Tests PowerBI Embedded Capacity lifecycle (Create, Update, Get, List, Delete).
#>
function Test-My
{
	# Creating capacity
	$RGlocation = Get-RG-Location
	$location = Get-Location
	$resourceGroupName = "onesdk1511"
	$capacityName = "onesdk7740"

	[array]$capacityGet = Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName
	$capacityGetItem = $capacityGet[0]

	Assert-True {$capacityGetItem.ProvisioningState -like "Succeeded"}
	Assert-True {$capacityGetItem.State -like "Succeeded"}
		
	Assert-AreEqual $capacityName $capacityGetItem.Name
	Assert-AreEqual $location $capacityGetItem.Location
	Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityGetItem.Type
	Assert-True {$capacityGetItem.Id -like "*$resourceGroupName*"}

		# Scale up A1 -> A2
		$capacityUpdated = Update-AzureRmPowerBIEmbeddedCapacity -Name $capacityName -Sku A2 -PassThru
		Assert-AreEqual A2 $capacityUpdated.Sku

		# Scale down A2 -> A1
		$capacityUpdated = Update-AzureRmPowerBIEmbeddedCapacity -Name $capacityName -Sku A1 -PassThru
		Assert-AreEqual A1 $capacityUpdated.Sku
}

<#
.SYNOPSIS
Tests PowerBI Embedded Capacity lifecycle (Create, Update, Get, List, Delete).
#>
function Test-PowerBIEmbeddedCapacity
{
	try
	{  
		# Creating capacity
		$RGlocation = Get-RG-Location
		$location = Get-Location
		$resourceGroupName = Get-ResourceGroupName
		$capacityName = Get-PowerBIEmbeddedCapacityName

		New-AzureRmResourceGroup -Name $resourceGroupName -Location $RGlocation
		
		$capacityCreated = New-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Location $location -Sku 'A1' -Administrator 'aztest0@stabletest.ccsctp.net','aztest1@stabletest.ccsctp.net'
    
		Assert-AreEqual $capacityName $capacityCreated.Name
		Assert-AreEqual $location $capacityCreated.Location
		Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityCreated.Type
		Assert-AreEqual 2 $capacityCreated.Administrators.Count
		Assert-True {$capacityCreated.Id -like "*$resourceGroupName*"}
	
		[array]$capacityGet = Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName
		$capacityGetItem = $capacityGet[0]

		Assert-True {$capacityGetItem.ProvisioningState -like "Succeeded"}
		Assert-True {$capacityGetItem.State -like "Succeeded"}
		
		Assert-AreEqual $capacityName $capacityGetItem.Name
		Assert-AreEqual $location $capacityGetItem.Location
		Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityGetItem.Type
		Assert-True {$capacityGetItem.Id -like "*$resourceGroupName*"}

		# Test to make sure the capacity does exist
		Assert-True {Test-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName}
		# Test it without specifying a resource group
		Assert-True {Test-AzureRmPowerBIEmbeddedCapacity -Name $capacityName}
		
		# Updating capacity
		$tagsToUpdate = @{"TestTag" = "TestUpdate"}
		$capacityUpdated = Update-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Tag $tagsToUpdate -PassThru
		Assert-NotNull $capacityUpdated.Tag "Tag do not exists"
		Assert-NotNull $capacityUpdated.Tag["TestTag"] "The updated tag 'TestTag' does not exist"
		Assert-AreEqual $capacityUpdated.Administrators.Count 2

		$capacityUpdated = Update-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Administrator 'aztest1@stabletest.ccsctp.net' -PassThru
		Assert-NotNull $capacityUpdated.Administrators "Capacity Administrator list is empty"
		Assert-AreEqual $capacityUpdated.Administrators.Count 1

		Assert-AreEqual $capacityName $capacityUpdated.Name
		Assert-AreEqual $location $capacityUpdated.Location
		Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityUpdated.Type
		Assert-True {$capacityUpdated.Id -like "*$resourceGroupName*"}

		# List all capacitys in resource group
		[array]$capacitysInResourceGroup = Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName
		Assert-True {$capacitysInResourceGroup.Count -ge 1}

		$found = 0
		for ($i = 0; $i -lt $capacitysInResourceGroup.Count; $i++)
		{
			if ($capacitysInResourceGroup[$i].Name -eq $capacityName)
			{
				$found = 1
				Assert-AreEqual $location $capacitysInResourceGroup[$i].Location
				Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacitysInResourceGroup[$i].Type
				Assert-True {$capacitysInResourceGroup[$i].Id -like "*$resourceGroupName*"}

				break
			}
		}
		Assert-True {$found -eq 1} "capacity created earlier is not found when listing all in resource group: $resourceGroupName."

		# List all PowerBI Embedded Capacities in subscription
		[array]$capacitysInSubscription = Get-AzureRmPowerBIEmbeddedCapacity
		Assert-True {$capacitysInSubscription.Count -ge 1}
		Assert-True {$capacitysInSubscription.Count -ge $capacitysInResourceGroup.Count}
    
		$found = 0
		for ($i = 0; $i -lt $capacitysInSubscription.Count; $i++)
		{
			if ($capacitysInSubscription[$i].Name -eq $capacityName)
			{
				$found = 1
				Assert-AreEqual $location $capacitysInSubscription[$i].Location
				Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacitysInSubscription[$i].Type
				Assert-True {$capacitysInSubscription[$i].Id -like "*$resourceGroupName*"}
    
				break
			}
		}
		Assert-True {$found -eq 1} "Account created earlier is not found when listing all in subscription."

		# Suspend PowerBI Embedded capacity
		Suspend-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName
		[array]$capacityGet = Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName
		$capacityGetItem = $capacityGet[0]
		# this is to ensure backward compatibility compatibility. The servie side would make change to differenciate state and provisioningState in future
		Assert-True {$capacityGetItem.State -like "Paused"}
		Assert-True {$capacityGetItem.ProvisioningState -like "Paused"}

		# Resume PowerBI Embedded capacity
		Resume-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName
		[array]$capacityGet = Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName
		$capacityGetItem = $capacityGet[0]
		Assert-True {$capacityGetItem.ProvisioningState -like "Succeeded"}
		Assert-True {$capacityGetItem.State -like "Succeeded"}
		
		# Delete PowerBI Embedded capacity
		Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -PassThru

		# Verify that it is gone by trying to get it again
		Assert-Throws {Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName}
	}
	finally
	{
		# cleanup the resource group that was used in case it still exists. This is a best effort task, we ignore failures here.
		Invoke-HandledCmdlet -Command {Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -ErrorAction SilentlyContinue} -IgnoreFailures
		Invoke-HandledCmdlet -Command {Remove-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue} -IgnoreFailures
	}
}

<#
.SYNOPSIS
Tests scale up and down of PowerBI Embedded Capacity (A1 -> A2 -> A1).
#>
function Test-PowerBIEmbeddedCapacityScaleUpDown
{
	try
	{  
		# Creating capacity
		$RGlocation = Get-RG-Location
		$location = Get-Location
		$resourceGroupName = Get-ResourceGroupName
		$capacityName = Get-PowerBIEmbeddedCapacityName

		New-AzureRmResourceGroup -Name $resourceGroupName -Location $RGlocation
		
		$capacityCreated = New-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Location $location -Sku 'A1' -Administrator 'aztest0@stabletest.ccsctp.net','aztest1@stabletest.ccsctp.net'
		Assert-AreEqual $capacityName $capacityCreated.Name
		Assert-AreEqual $location $capacityCreated.Location
		Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityCreated.Type
		Assert-AreEqual A1 $capacityCreated.Sku
		Assert-True {$capacityCreated.Id -like "*$resourceGroupName*"}
	
		# Check capacity was created successfully
		[array]$capacityGet = Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName
		$capacityGetItem = $capacityGet[0]

		Assert-True {$capacityGetItem.ProvisioningState -like "Succeeded"}
		Assert-True {$capacityGetItem.State -like "Succeeded"}
		
		Assert-AreEqual $capacityName $capacityGetItem.Name
		Assert-AreEqual $location $capacityGetItem.Location
		Assert-AreEqual A1 $capacityGetItem.Sku
		Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityGetItem.Type
		Assert-True {$capacityGetItem.Id -like "*$resourceGroupName*"}
		
		# Scale up A1 -> A2
		$capacityUpdated = Update-AzureRmPowerBIEmbeddedCapacity -Name $capacityName -Sku A2 -PassThru
		Assert-AreEqual A2 $capacityUpdated.Sku

		# Scale down A2 -> A1
		$capacityUpdated = Update-AzureRmPowerBIEmbeddedCapacity -Name $capacityName -Sku A1 -PassThru
		Assert-AreEqual A1 $capacityUpdated.Sku
		
		# Delete PowerBI Embedded capacity
		Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -PassThru
	}
	finally
	{
		# cleanup the resource group that was used in case it still exists. This is a best effort task, we ignore failures here.
		Invoke-HandledCmdlet -Command {Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -ErrorAction SilentlyContinue} -IgnoreFailures
		Invoke-HandledCmdlet -Command {Remove-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue} -IgnoreFailures
	}
}

<#
.SYNOPSIS
Tests PowerBI Embedded Capacity lifecycle  Failure scenarios (Create, Update, Get, Delete).
#>
function Test-NegativePowerBIEmbeddedCapacity
{
    param
	(
		$fakecapacityName = "psfakecapacitytest",
		$invalidSku = "INVALID"
	)
	
	try
	{
		# Creating Account
		$RGlocation = Get-RG-Location
		$location = Get-Location
		$resourceGroupName = Get-ResourceGroupName
		$capacityName = Get-PowerBIEmbeddedCapacityName
		
		New-AzureRmResourceGroup -Name $resourceGroupName -Location $RGlocation
		$capacityCreated = New-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Location $location -Sku 'A1' -Administrator 'aztest0@stabletest.ccsctp.net','aztest1@stabletest.ccsctp.net'

		Assert-AreEqual $capacityName $capacityCreated.Name
		Assert-AreEqual $location $capacityCreated.Location
		Assert-AreEqual "Microsoft.PowerBIDedicated/capacities" $capacityCreated.Type
		Assert-True {$capacityCreated.Id -like "*$resourceGroupName*"}

		# attempt to recreate the already created capacity
		Assert-Throws {New-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Location $location}

		# attempt to update a non-existent capacity
		$tagsToUpdate = @{"TestTag" = "TestUpdate"}
		Assert-Throws {Update-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $fakecapacityName -Tag $tagsToUpdate}

		# attempt to get a non-existent capacity
		Assert-Throws {Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $fakecapacityName}

		# attempt to create a capacity with invalid Sku
		Assert-Throws {New-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $fakecapacityName -Location $location -Sku $invalidSku -Administrator 'aztest0@stabletest.ccsctp.net','aztest1@stabletest.ccsctp.net'}

		# attempt to scale a capacity to invalid Sku
		Assert-Throws {Update-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -Sku $invalidSku}

		# Delete PowerBI Embedded capacity
		Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -PassThru

		# Delete PowerBI Embedded capacity again should throw.
		Assert-Throws {Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -PassThru}

		# Verify that it is gone by trying to get it again
		Assert-Throws {Get-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName}
	}
	finally
	{
		# cleanup the resource group that was used in case it still exists. This is a best effort task, we ignore failures here.
		Invoke-HandledCmdlet -Command {Remove-AzureRmPowerBIEmbeddedCapacity -ResourceGroupName $resourceGroupName -Name $capacityName -ErrorAction SilentlyContinue} -IgnoreFailures
		Invoke-HandledCmdlet -Command {Remove-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue} -IgnoreFailures
	}
}
