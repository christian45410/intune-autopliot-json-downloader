<#
    .NOTES
    ---------------------------------------------------
     Script create by:  Christian Lancaster
     Generated on:       06/12/2023
    ---------------------------------------------------
    .DESCRIPTION
        GUI script to login to the Graph API and download the AutopilotConfigurationFile.json file from Intune tenant.
#>


function Show-IntuneAutopilotJsonDownloader {

	[void][reflection.assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')

	[System.Windows.Forms.Application]::EnableVisualStyles()
	$formIntuneAutopilotJsonD = New-Object 'System.Windows.Forms.Form'
	$listboxProfiles = New-Object 'System.Windows.Forms.ListBox'
	$buttonSave = New-Object 'System.Windows.Forms.Button'
	$textboxPath = New-Object 'System.Windows.Forms.TextBox'
	$buttonBrowse = New-Object 'System.Windows.Forms.Button'
	$buttonUpdateModules = New-Object 'System.Windows.Forms.Button'
	$buttonConnectToGraphAPI = New-Object 'System.Windows.Forms.Button'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'

	$formIntuneAutopilotJsonD_Load={
		#Initialize Form Controls
		Import-Module AzureAD
		Import-Module Microsoft.Graph.Intune
		Import-Module WindowsAutopilotIntune
	}
	
	function Update-ListBox
	{		
		param
		(
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			[System.Windows.Forms.ListBox]
			$ListBox,
			[Parameter(Mandatory = $true)]
			[ValidateNotNull()]
			$Items,
			[Parameter(Mandatory = $false)]
			[string]$DisplayMember,
			[Parameter(Mandatory = $false)]
			[string]$ValueMember,
			[switch]
			$Append
		)
		
		if (-not $Append)
		{
			$ListBox.Items.Clear()
		}
		
		if ($Items -is [System.Windows.Forms.ListBox+ObjectCollection] -or $Items -is [System.Collections.ICollection])
		{
			$ListBox.Items.AddRange($Items)
		}
		elseif ($Items -is [System.Collections.IEnumerable])
		{
			$ListBox.BeginUpdate()
			foreach ($obj in $Items)
			{
				$ListBox.Items.Add($obj)
			}
			$ListBox.EndUpdate()
		}
		else
		{
			$ListBox.Items.Add($Items)
		}
		
		if ($DisplayMember)
		{
			$ListBox.DisplayMember = $DisplayMember
		}
		if ($ValueMember)
		{
			$ListBox.ValueMember = $ValueMember
		}
	}
		
	$buttonConnectToGraphAPI_Click={
		Connect-MSGraph
		Disconnect-Graph
		Connect-Graph
		$listBoxProfiles.Items.Clear()
		$AutopilotProfile = Get-AutopilotProfile
		foreach ($profile in $AutopilotProfile)
		{
			$listBoxProfiles.Items.Add($profile.displayName)
		}
		[System.Windows.Forms.MessageBox]::Show("Connected to Azure tenant.", "Information", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
		$buttonBrowse.Enabled = "true"
	}
	
	$buttonUpdateModules_Click={
		# Specify the names of the modules you want to check/install
		$modules = "AzureAD", "Microsoft.Graph.Intune", "WindowsAutopilotIntune"
		
		foreach ($module in $modules)
		{
			if (Get-Module -ListAvailable -Name $module)
			{
				[System.Windows.Forms.MessageBox]::Show("$module is already installed.", "Information", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
			}
			else
			{
				Install-Module -Name $module -Force
				[System.Windows.Forms.MessageBox]::Show("$module has been installed.", "Information", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
			}
		}
		Import-Module AzureAD
		Import-Module Microsoft.Graph.Intune
		Import-Module WindowsAutopilotIntune
	}
	
	$buttonBrowse_Click={
		Add-Type -AssemblyName System.Windows.Forms
		
		# Create an instance of the FolderBrowserDialog
		$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
		
		# Show the dialog and wait for user input
		$dialogResult = $folderBrowser.ShowDialog()
		
		# Check if the user clicked OK
		if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK)
		{
			
			# Get the selected directory path
			$selectedDirectory = $folderBrowser.SelectedPath
			$textBoxPath.Text = $selectedDirectory
			[System.Windows.Forms.MessageBox]::Show("Selected directory:`n`n$selectedDirectory", "Information", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
			$buttonSave.Enabled = "true"
		}
		else
		{
			[System.Windows.Forms.MessageBox]::Show("No directory selected.", "Error", "OK", [System.Windows.Forms.MessageBoxIcon]::Error)
			$buttonSave.Enabled = "false"
		}	
	}
	
	$buttonSave_Click={
		$AutopilotProfile = Get-AutopilotProfile
		$selectedIndex = $listBoxProfiles.SelectedIndex
		if ($selectedIndex -ge 0)
		{
			$selectedProfile = $listBoxProfiles.SelectedItem.ToString()
			$profile = $AutopilotProfile | Where-Object { $_.displayName -eq $selectedProfile }
			$json = $profile | ConvertTo-AutopilotConfigurationJSON
			$fullPath = Join-Path -Path $textBoxPath.Text -ChildPath "\AutopilotConfigurationFile.json"
			$json | Out-File -Encoding Ascii -FilePath $fullPath
			[System.Windows.Forms.MessageBox]::Show("JSON file downloaded for profile:`n`n$($profile.displayName)", "Information", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
		}
		else
		{
			[System.Windows.Forms.MessageBox]::Show("No profile selected.", "Error", "OK", [System.Windows.Forms.MessageBoxIcon]::Error)
		}
	}
		
	$Form_StateCorrection_Load=
	{
		$formIntuneAutopilotJsonD.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		try
		{
			$buttonSave.remove_Click($buttonSave_Click)
			$buttonBrowse.remove_Click($buttonBrowse_Click)
			$buttonUpdateModules.remove_Click($buttonUpdateModules_Click)
			$buttonConnectToGraphAPI.remove_Click($buttonConnectToGraphAPI_Click)
			$formIntuneAutopilotJsonD.remove_Load($formIntuneAutopilotJsonD_Load)
			$formIntuneAutopilotJsonD.remove_Load($Form_StateCorrection_Load)
			$formIntuneAutopilotJsonD.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}

	$formIntuneAutopilotJsonD.SuspendLayout()
	#
	# formIntuneAutopilotJsonDownloader
	#
	$formIntuneAutopilotJsonD.Controls.Add($listboxProfiles)
	$formIntuneAutopilotJsonD.Controls.Add($buttonSave)
	$formIntuneAutopilotJsonD.Controls.Add($textboxPath)
	$formIntuneAutopilotJsonD.Controls.Add($buttonBrowse)
	$formIntuneAutopilotJsonD.Controls.Add($buttonUpdateModules)
	$formIntuneAutopilotJsonD.Controls.Add($buttonConnectToGraphAPI)
	$formIntuneAutopilotJsonD.AutoScaleDimensions = New-Object System.Drawing.SizeF(6, 13)
	$formIntuneAutopilotJsonD.AutoScaleMode = 'Font'
	$formIntuneAutopilotJsonD.ClientSize = New-Object System.Drawing.Size(439, 158)
	$formIntuneAutopilotJsonD.Name = 'formIntuneAutopilotJsonD'
	$formIntuneAutopilotJsonD.Text = 'Intune Autopilot Json Downloader'
	$formIntuneAutopilotJsonD.add_Load($formIntuneAutopilotJsonD_Load)
	#
	# listboxProfiles
	#
	$listboxProfiles.FormattingEnabled = $True
	$listboxProfiles.Location = New-Object System.Drawing.Point(255, 12)
	$listboxProfiles.Name = 'listboxProfiles'
	$listboxProfiles.Size = New-Object System.Drawing.Size(169, 134)
	$listboxProfiles.TabIndex = 5
	#
	# buttonSave
	#
	$buttonSave.Location = New-Object System.Drawing.Point(12, 126)
	$buttonSave.Name = 'buttonSave'
	$buttonSave.Size = New-Object System.Drawing.Size(237, 23)
	$buttonSave.TabIndex = 4
	$buttonSave.Text = 'Save'
	$buttonSave.UseVisualStyleBackColor = $True
	$buttonSave.add_Click($buttonSave_Click)
	#
	# textboxPath
	#
	$textboxPath.Location = New-Object System.Drawing.Point(12, 71)
	$textboxPath.Name = 'textboxPath'
	$textboxPath.Size = New-Object System.Drawing.Size(237, 20)
	$textboxPath.TabIndex = 3
	#
	# buttonBrowse
	#
	$buttonBrowse.Location = New-Object System.Drawing.Point(174, 97)
	$buttonBrowse.Name = 'buttonBrowse'
	$buttonBrowse.Size = New-Object System.Drawing.Size(75, 23)
	$buttonBrowse.TabIndex = 2
	$buttonBrowse.Text = 'Browse'
	$buttonBrowse.UseVisualStyleBackColor = $True
	$buttonBrowse.add_Click($buttonBrowse_Click)
	#
	# buttonUpdateModules
	#
	$buttonUpdateModules.Location = New-Object System.Drawing.Point(174, 12)
	$buttonUpdateModules.Name = 'buttonUpdateModules'
	$buttonUpdateModules.Size = New-Object System.Drawing.Size(75, 53)
	$buttonUpdateModules.TabIndex = 1
	$buttonUpdateModules.Text = 'Update Modules'
	$buttonUpdateModules.UseVisualStyleBackColor = $True
	$buttonUpdateModules.add_Click($buttonUpdateModules_Click)
	#
	# buttonConnectToGraphAPI
	#
	$buttonConnectToGraphAPI.Location = New-Object System.Drawing.Point(12, 12)
	$buttonConnectToGraphAPI.Name = 'buttonConnectToGraphAPI'
	$buttonConnectToGraphAPI.Size = New-Object System.Drawing.Size(156, 53)
	$buttonConnectToGraphAPI.TabIndex = 0
	$buttonConnectToGraphAPI.Text = 'Connect to Graph API'
	$buttonConnectToGraphAPI.UseVisualStyleBackColor = $True
	$buttonConnectToGraphAPI.add_Click($buttonConnectToGraphAPI_Click)


	$InitialFormWindowState = $formIntuneAutopilotJsonD.WindowState
	$formIntuneAutopilotJsonD.add_Load($Form_StateCorrection_Load)
	$formIntuneAutopilotJsonD.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $formIntuneAutopilotJsonD.ShowDialog()

} 

#Call form
Show-IntuneAutopilotJsonDownloader | Out-Null
