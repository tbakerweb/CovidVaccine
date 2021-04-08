<#
	Get-CovidVaccineAppointments.ps1

	Author: Tony Baker www.github.com/tbakerweb
	Date: 2021-04-07

	Synopsis:
		This script uses the CVS and Walgreens website and looks for available appointments using their systems.

		The parameters defined are used in the script to specify the correct location to find appointments in.

		The defaults in this script suit _my_ needs and unless you live near me, you'll have to change them to suit your location



#>
[CmdletBinding()]
param (
	
	## Check Sites
	[Parameter()][bool]$CVS = $True,
	[Parameter()][Boolean]$Walgreens = $False,

	[Parameter()][Int16]$PollIntervalSeconds = 60,


	##
	## CVS Related Lookup Settings
	##

	## State, use 2 letter, lowercase
	[Parameter()]
	[String]
	$State = 'ma',
	
	## List the names of the cities CVS Lists appointments for. 
	## Use the Vaccine Appointment finder on cvs.com to determine what cities they offer vaccines in.
	[Parameter()]
	[String[]]$LocalCities = @(
		'Acton',
		'Concord',
		'Fitchburg',
		'Gardner',
		'Leominster'
		'Lunenburg',
		'Marlborough',
		'Westborough',
		'Winchendon',
		'Worcester'),

	##
	##	Walgreens Settings
	##		The Walgreens lookup uses Latitude and Longitude to perform the localized search.
	## 		Leaving the Lat/Lon blank will force a lookup using the zip code

	## Zip Code
	[Parameter()]
	[String]$ZipCode = '01420',
	
	## Latitude and Longitude
	[Parameter()]
	[String]$Latitude,
	[Parameter()]
	[String]$Longitude
	
)
	
Begin {

	## Get Tomorrows date to lookup appointments
	$Tomorrow = Get-Date -Date ((Get-Date).AddDays(1)) -Format "yyyy-MM-dd"
		
	## Create a Web Session to Walgreens and to CVS
	if ($CVS) {
		Invoke-WebRequest -Uri 'https://www.cvs.com' -SessionVariable $HttpSessionCVS | Out-Null
	}
	if ($Walgreens) {
		Invoke-WebRequest -Uri 'https://www.walgreens.com' -SessionVariable $HttpSessionWalgreens | Out-Null
		
		## Check if Lat/Lon are known
		if (-not $Latitude -and -not $Longitude -and $ZipCode) {
			
			## Notify the lookup occuring
			Write-Host 'Latitude and Longitude are not known. Looking up from Zip Code: ' -NoNewline
			Write-Host $ZipCode -ForegroundColor Yellow
			
			## Perform a Lat/Lon lookup if none was provided
			$LocationLookupRequest = @{
				Uri     = "https://public.opendatasoft.com/api/records/1.0/search/?rows=40&q=$ZipCode&start=0&fields=latitude,longitude,city,state&dataset=us-zip-code-latitude-and-longitude&timezone=America%2FNew_York&lang=en"
				Headers = @{
					"method" = "GET"
				}
			}
			
			## Make the Location Lookup request
			$LocationResult = Invoke-WebRequest @LocationLookupRequest
			$LocationContent = $LocationResult.Content | ConvertFrom-Json
			
			## Collect the Latitude and Longitude from the Query
			$Location = $LocationContent.records[0].fields
			# $Latitude = $LocationContent.records[0].fields.latitude
			# $Longitude = $LocationContent.records[0].fields.longitude
			# $ZipCity = $LocationContent.records[0].fields.city
			# $ZipCity = $LocationContent.records[0].fields.state
			
			## Display the Details to the user
			Write-Host "Latitude: " -NoNewline
			Write-Host $Location.Latitude -ForegroundColor Cyan -NoNewline
			Write-Host ",  Longitude: " -NoNewline
			Write-Host $Location.Longitude -ForegroundColor Cyan -NoNewline
			Write-Host ' for ' $Location.city ', ' $Location.state
			
		}
		
		## Use the Walgreens Connection to get the CSRF token for the ongoing connections
		$WalgreensCsrfRequest = @{
			Uri        = "https://www.walgreens.com/browse/v1/csrf"
			WebSession = $HttpSessionWalgreens
			Method     = "GET" 
			Headers    = @{
				"method"           = "GET"
				"authority"        = "www.walgreens.com"
				"scheme"           = "https"
				"path"             = "/browse/v1/csrf"
				"pragma"           = "no-cache"
				"cache-control"    = "no-cache"
				"sec-ch-ua"        = "`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not\`"A\\Brand`";v=`"99`""
				"accept"           = "application/json, text/plain, */*"
				"dnt"              = "1"
				"sec-ch-ua-mobile" = "?1"
				"user-agent"       = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Mobile Safari/537.36"
				"sec-fetch-site"   = "same-origin"
				"sec-fetch-mode"   = "cors"
				"sec-fetch-dest"   = "empty"
				"referer"          = "https://www.walgreens.com/"
				"accept-encoding"  = "gzip, deflate, br"
				"accept-language"  = "en-US,en;q=0.9"
				
			}
			# ContentType = "application/json; charset=UTF-8"
			# Body        = "{`"serviceId`":`"99`",`"position`":{`"latitude`":$Latitude,`"longitude`":$Longitude},`"appointmentAvailability`":{`"startDateTime`":`"$Tomorrow`"},`"radius`":25}"
		}
		$WalgreensCsrfResponse = Invoke-WebRequest @WalgreensCsrfRequest
		$WalgreensCsrfContent = $WalgreensCsrfResponse.content | ConvertFrom-Json
		$WalgreensCsrfHeader = $WalgreensCsrfContent.csrfHeaderName
		$WalgreensCsrfToken = $WalgreensCsrfContent.csrfToken
		$WalgreensCookies = $WalgreensCsrfResponse.Headers.'Set-Cookie' -join ''
		# $WalgreensCsrfCookie = $WalgreensCookies | Foreach-Object {
			
		# 	## Only get the Cookie setting who's prefix is the XSRF token
		# 	if ($_.Substring(0, 4) -eq 'XSRF') {
		# 		return $_ -replace 'XSRF-TOKEN=', ''
		# 	}
		# }
	}
}
			
Process {
				
	## Write a welcome header
	Write-Host 'Checking for Vaccine appointments'
	if ($CVS) { 
		Write-Host "	CVS Locations ($State): " -NoNewline 
		Write-Host ($LocalCities -join ', ') -ForegroundColor Cyan
	}
	
	if ($Walgreens) { 
		Write-Host '	Walgreens Near: ' -NoNewline 
		Write-Host $ZipCode -ForegroundColor Cyan
	}
	
	## Keep running until interrupted
	while (-Not $Booked) {
		
		## Setup a Local Appointments List
		$LocalAppointments = [System.Collections.ArrayList]@()
		

		if ($CVS) {

			## Create the CVS Request
			$CVSRequest = @{
				Uri        = "https://www.cvs.com/immunizations/covid-19-vaccine.vaccine-status.$State.json?vaccineinfo"
				WebSession = $HttpSessionCVS
				Headers    = @{
					"method"           = "GET"
					"authority"        = "www.cvs.com"
					"scheme"           = "https"
					"path"             = "/immunizations/covid-19-vaccine.vaccine-status.$State.json?vaccineinfo"
					"pragma"           = "no-cache"
					"cache-control"    = "no-cache"
					"sec-ch-ua"        = "`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not\`"A\\Brand`";v=`"99`""
					"dnt"              = "1"
					"sec-ch-ua-mobile" = "?1"
					"user-agent"       = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Mobile Safari/537.36"
					"accept"           = "*/*"
					"sec-fetch-site"   = "same-origin"
					"sec-fetch-mode"   = "cors"
					"sec-fetch-dest"   = "empty"
					"referer"          = "https://www.cvs.com/immunizations/covid-19-vaccine?icid=cvs-home-hero1-link2-coronavirus-vaccine"
					"accept-encoding"  = "gzip, deflate, br"
					"accept-language"  = "en-US,en;q=0.9"
				}
			}
			
			## Send the CVS Request, get a response
			$CVSResponse = Invoke-WebRequest @CVSRequest
			
			## Response Content
			$CVSContent = $CVSResponse.Content | ConvertFrom-Json
		
			## Parce the CVS response for local cities
			$CVSContent.responsePayloadData.data.($State.ToUpper()) | ForEach-Object { 
				
				## Filter to only local cities
				if ($_.city.ToLower() -in $LocalCities.ToLower()) {
					
					## If there are appointments available
					if ($_.status -ne 'Fully Booked') {
						
						## Add the City to the LocalAppointments Array
						$LocalAppointments.Add('CVS: ' + $_.city + ', Status: ' + $_.status) | Out-Null
					}
				}
			}
		}		
		
		
		if ($Walgreens) {

			## Get Walgreens availablity
			$Tomorrow = Get-Date -Date ((Get-Date).AddDays(1)) -Format "yyyy-MM-dd"
			
			## Prepare the Request for Walgreens
			$WalgreensRequest = @{
				
				Uri         = "https://www.walgreens.com/hcschedulersvc/svc/v1/immunizationLocations/availability" 
				WebSession  = $HttpSessionWalgreens
				Method      = "POST" 
				Headers     = @{
					"method"           = "POST"
					"authority"        = "www.walgreens.com"
					"scheme"           = "https"
					"path"             = "/hcschedulersvc/svc/v1/immunizationLocations/availability"
					"pragma"           = "no-cache"
					"cache-control"    = "no-cache"
					"sec-ch-ua"        = "`"Google Chrome`";v=`"89`", `"Chromium`";v=`"89`", `";Not\`"A\\Brand`";v=`"99`""
					"accept"           = "application/json, text/plain, */*"
					"dnt"              = "1"
					"sec-ch-ua-mobile" = "?1"
					"user-agent"       = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Mobile Safari/537.36"
					"origin"           = "https://www.walgreens.com"
					"sec-fetch-site"   = "same-origin"
					"sec-fetch-mode"   = "cors"
					"sec-fetch-dest"   = "empty"
					"referer"          = "https://www.walgreens.com/findcare/vaccination/covid-19/location-screening"
					"accept-encoding"  = "gzip, deflate, br"
					"accept-language"  = "en-US,en;q=0.9"
					# "cookie"             = $WalgreensCookies
					# $WalgreensCsrfHeader.tolower() = $WalgreensCsrfToken
				}
				ContentType = "application/json; charset=UTF-8" 
				Body        = "{`"serviceId`":`"99`",`"position`":{`"latitude`":$Latitude,`"longitude`":$Longitude},`"appointmentAvailability`":{`"startDateTime`":`"$Tomorrow`"},`"radius`":25}"
			}
		
			## Send the request, get the response
			$WalgreensResponse = Invoke-WebRequest @WalgreensRequest -ErrorAction 'SilentlyContinue'
		
			## Parse the Walgreens Response
			$WalgreensContent = $WalgreensResponse.Content | ConvertFrom-Json
		
			## Test if Walgreens has appointments
			if ($WalgreensContent.appointmentsAvailable) {
				## Add the City to the LocalAppointments Array
				$LocalAppointments.Add('Walgreens:' + $WalgreensContent.availabilityGroups) | Out-Null
			}
		}
		
		## Write the output
		Write-Host (Get-Date)'- ' -NoNewline
		if ($LocalAppointments.Count -eq 0) {
			Write-Host 'No appointments Available' -ForegroundColor Red
		} else {
			Write-Host 'Appointments Available at: ' ($LocalAppointments -join ', ') -ForegroundColor Green
			$player = New-Object -TypeName System.Media.SoundPlayer
			$player.SoundLocation = 'C:\Windows\Media\Windows Proximity Connection.wav'
			$player.Play()
			$player.Play()
			$player.Play()
			$player.Play()
		}
		Start-Sleep -Seconds $PollIntervalSeconds
	
	}
}

End {

}