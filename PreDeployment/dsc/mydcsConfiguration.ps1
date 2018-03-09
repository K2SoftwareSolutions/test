Configuration Main
{
	Param ( [string] $nodeName, [string] $PBIDLink, [string] $PBIDProductId )

	Import-DscResource -ModuleName PSDesiredStateConfiguration
	Import-DSCResource -Module xSystemSecurity -Name xIEEsc -ModuleVersion "1.2.0.0"
	Import-DscResource -module xChrome -Name MSFT_xChrome -ModuleVersion "1.1.0.0"
	Import-DscResource -module xPSDesiredStateConfiguration -Name xRemoteFile -ModuleVersion "4.0.0.0"
	Import-DscResource -module xHyper-V -Name xHyper-V -ModuleVersion "3.11.0.0"
	Import-DscResource -module cDscDocker -Name cDscDocker -ModuleVersion "1.2.0"

	Node $nodeName
	{

		xIEEsc DisableIEEscAdmin
		{
			IsEnabled = $false
			UserRole  = "Administrators"
		}

		xIEEsc DisableIEEsc
		{
			IsEnabled = $false
			UserRole = "Users"
		}

		Registry EnableDownloads
		{
			Ensure = "Present"
			Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
			ValueName = "1803"
			ValueData = "0"
			ValueType = "Dword"
		}

		Registry DisablePopUp
		{
			Ensure = "Present"
			Key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
			ValueName = "1809"
			ValueData = "3"
			ValueType = "Dword"
		}

		Registry DoNotOpenServerManager
		{
			Ensure = "Present"
			Key = "HKLM:\SOFTWARE\Microsoft\ServerManager"
			ValueName = "DoNotOpenServerManagerAtLogon"
			ValueData = "1"
			ValueType = "Dword"
		}
		
		MSFT_xChrome chrome
		{
			Language = "en"
			LocalPath = "$env:SystemDrive\Windows\DtlDownloads\GoogleChromeStandaloneEnterprise.msi"
		}
		
		xRemoteFile PBIDownload
		{
			Uri = $PBIDLink
			DestinationPath = "c:\temp\PowerBIDesktop.msi"
		}
		
		Package Installer
		{
			Ensure = "Present"
			Path = "c:\temp\PowerBIDesktop.msi"
			Name = "Microsoft Power BI Desktop (x64)"
			ProductId = $PBIDProductId
			DependsOn = "[xRemoteFile]PBIDownload"
			Arguments = "ACCEPT_EULA=1 /passive"
			LogPath = "c:\temp\PowerBIDesktop_InstallLog.log"
		}

		LocalConfigurationManager
		{
			RebootNodeIfNeeded = $true
		}

        cDscDocker docker
        {
			docker = "docker"
			Ensure = 'Present'
			Swarm = 'Active'
			SwarmURI = "SWMTKN-1-ETCETCETC"
			exposeApi = $true
			daemonInterface = "tcp://0.0.0.0:2375"
        }
	}
}