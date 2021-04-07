
## Define local cities, for CVS Lookup
$LocalCities = @(
	'Acton',
	'Concord',
	'Fitchburg',
	'Garder',
	'Leominster'
	'Lunenburg',
	'Marlborough',
	'Westborough',
	'Winchendon',
	'Worcester'
)

## Write a welcome header
Write-Host 'Checking for Vaccine appointments at: CVS and Walgreens'
Write-Host 'Checking CVS Locations: '($LocalCities -join ', ')

## Keep running until interrupted
while (-Not $Booked) {
	
	## Setup a Local Appointments List
	$LocalAppointments = [System.Collections.ArrayList]@()

	## Create the CVS Request
	$CVSRequest = @{
		Uri     = "https://www.cvs.com/immunizations/covid-19-vaccine.vaccine-status.ma.json?vaccineinfo"
		Headers = @{
			"method"           = "GET"
			"authority"        = "www.cvs.com"
			"scheme"           = "https"
			"path"             = "/immunizations/covid-19-vaccine.vaccine-status.ma.json?vaccineinfo"
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
			"cookie"           = "pe=p1; aat1=off-p1; acctdel_v1=on; adh_new_ps=on; adh_ps_pickup=on; adh_ps_refill=on; buynow=off; sab_displayads=on; dashboard_v1=off; db-show-allrx=on; disable-app-dynamics=on; disable-sac=on; dpp_cdc=off; dpp_drug_dir=off; dpp_sft=off; getcust_elastic=on; echomeln6=on; enable_imz=on; enable_imz_cvd=on; enable_imz_reschedule_instore=on; enable_imz_reschedule_clinic=off; flipp2=on; gbi_cvs_coupons=true; ice-phr-offer=off; v3redirecton=false; mc_cloud_service=on; mc_hl7=on; mc_home_new=off1; mc_ui_ssr=off-p0; mc_videovisit=on; memberlite=on; pauth_v1=on; pivotal_forgot_password=off-p0; pivotal_sso=off-p0; pbmplaceorder=off; pbmrxhistory=on; ps=on; refill_chkbox_remove=off-p0; rxdanshownba=off; rxdfixie=on; rxd_bnr=on; rxd_dot_bnr=on; rxdpromo=on; rxduan=on; rxlite=on; rxlitelob=off; rxm=on; rxm_phone_dob=off-p1; rxm_demo_hide_LN=off; rxm_phdob_hide_LN=on; rxm_rx_challenge=off; s2c_akamaidigitizecoupon=on; s2c_beautyclub=off-p0; s2c_digitizecoupon=on; s2c_dmenrollment=off-p0; s2c_herotimer=off-p0; s2c_newcard=off-p0; s2c_papercoupon=on; s2c_persistEcCookie=on; s2c_rewardstrackerbctile=on; s2c_rewardstrackerbctenpercent=on; s2c_rewardstrackerqebtile=on; s2c_rewardstrackerbcpilotue=off; s2c_smsenrollment=on; s2cHero_lean6=on; sft_mfr_new=on; sftg=on; show_exception_status=on; v2-dash-redirection=on; bm_sz=BD3C37593E25D49C198BBCDE5CE00CDD~YAAQS9/aFyZAJHJ4AQAAaNWKqgume9HYJtOb2cFVbgTcmU3/JHf2cmFy4NuSt+rk/f5xvozsh4i+aIcI6lm6OmjSCSTm5+TqfdjmBjBH8mxbg7u19WUpkanHlTG+/5VVZvjtACQZ7z/OLZ/igAIL8J3slvrNzj4w7JGaE/tVvrVmlNvNLVBijhBL1vOl; gbi_sessionId=ckn6xuq6700003r7wu3q7csfa; gbi_visitorId=ckn6xuq6800013r7wzk29yx0c; _abck=7CE56E572849BFC8AB74E914CD25ABBC~0~YAAQS9/aF2FAJHJ4AQAAhu+KqgVqTaHCMndcxQk5AuPNNo7G+Qb6moY/DYhKiPqN+z8n4fc5rM8ijSzz/dnXRM9oVwTCmNaXfaSVaFgKfRIlBSAgdYOoHgZ8RRtLQUO0kjAQH522E2KbVi7m5Hs5xvDwV2KeGh/OlzvzpCUz8mgLgcTKvC1VVD9o3i9qEU9LfoAYHUz+B72MqJeTR0UtPhhy8dbhGsVlxlsxpAsCZzwVeOZRV/qnLx9sreVm2nxIriMQ2q5Z3RFY4keBsrvEEwvck626mlq1tvSAlQvbpyYmEbhgC/QLpM+peq0Bm3LhJM9F3e+23QEFHSNGWZqY2+qwEQMyyc25oWwqcY0plTH0s8RlwHMuQwm/gxyEYV6/BlhX21NXmnkwOEhLSPyIkqpEubbWSA==~-1~||-1||~-1; ak_bmsc=0536A60606C5A8CC9FB316B977DE7C7017DADF4BBC620000E0316D60BC4A7C05~plWaJBiQ2IalkEd2y2+o7yLXY8fnv3NOeoeo7sUYHc/sggY+9BRi5VJa19WwYTaEgjCpvqYT3HPbulz7Y3F0YGZcJb8vFqH14PcYDI1/uUd5G4lI3Pvg8hDmOEW09C90quOnBz57LR9xp1KH99lxNUsuQ9B57MFQ8ZSR1kbsGfgAbs6OetbDHdKbC0WOjulu+SMYcER4+gEmIN/JHkRk95zX7FRh0Ox8ffiP/UaM2UNQuxc9zKj6N65/QcZv+lV/a8; bm_sv=C23EF8E23045A9E666A447469AC594F8~wTsrlTZkEOzrt+Z9vQDsZ2u4D4POXvY1NOsV7AD2XzSDsXSFqr11hGUA3VnmTlz0Ez1yrtqlX95ZWOvhBf7rVe+XjIVLxevhrqXqn9b73+BtxDzude8zkjoc48DWuvw1BLOXlKiIzyuepmy8wDW1cA==; akavpau_www_cvs_com_general=1617769366~id=f29ba89e2c6a898bdc302bed18d47a3b; CVPF=CT-1"
		}
	}

	## Send the CVS Request, get a response
	$CVSResponse = Invoke-WebRequest @CVSRequest

	## Response Content
	$CVSContent = $CVSResponse.Content | ConvertFrom-Json

	## Parce the CVS response for local cities
	$CVSContent.responsePayloadData.data.MA | ForEach-Object { 
		
		## Filter to only local cities
		if ($_.city.ToLower() -in $LocalCities.ToLower()) {

			## If there are appointments available
			if ($_.status -ne 'Fully Booked') {

				## Add the City to the LocalAppointments Array
				$LocalAppointments.Add('CVS: ' + $_) | Out-Null
			}
		}
	}

	## Get Walgreens availablity
	$Tomorrow = Get-Date -Date ((Get-Date).AddDays(1)) -Format "yyyy-MM-dd"
	
	## Prepare the Request for Walgreens
	$WalgreensRequest = @{

		Uri         = "https://www.walgreens.com/hcschedulersvc/svc/v1/immunizationLocations/availability" 
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
			"x-xsrf-token"     = "MPiuAXpuvnGU3w==.1KkyUVvtjDba4bWH3MeaEo4MRXb4sbxyDut3kV3iFRk="
			"sec-ch-ua-mobile" = "?1"
			"user-agent"       = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Mobile Safari/537.36"
			"origin"           = "https://www.walgreens.com"
			"sec-fetch-site"   = "same-origin"
			"sec-fetch-mode"   = "cors"
			"sec-fetch-dest"   = "empty"
			"referer"          = "https://www.walgreens.com/findcare/vaccination/covid-19/location-screening"
			"accept-encoding"  = "gzip, deflate, br"
			"accept-language"  = "en-US,en;q=0.9"
			"cookie"           = "bm_sz=EB00520479C40CC1A84B98AE7D816C98~YAAQkWvcF/QhTIV4AQAAeX0rrQsTp2fucFn7nTkUch8g+Xgaw8GGYEFBdzAtO1iMRoEaxJafVraUKPbuL5nMDTQyvGy0iels1Lm+rPyfiVms+llexUKEz/Kz++cCqG8V6BQMA31QQNGs09OJnLcCUFxeMlctMQ6NK1fZfqL5YtQ9MUj98GGIf7m/LVY63My3i1F9; rxVisitor=1617813013363ICFRLPOEAFG7HKEG97KCUR4H2CQN9SB5; wag_sid=neu6n43fpzjp1la97y8u58yh; uts=1617813014925; bm_mi=2ACD93529527B9D0D77541FD3381F735~dWBIr2Cz+BEjDfC2/uBIgz2b4Fd7udAxQnIm1nZV0xBvcSDZXQdku6kZ14c3j+lE2cw8xs6vl9xHD5FNfZtjMkym7z9oLPvXFXaYjoUfg2vtLVR/kiZBCK9qxIbLhW1ZnqEzsVm1fHXOLuAPxzZAuOlRHLXSuhvcB64R7xI1EyAFFl6AkdyhYzj/5aPTrjLMyLm1phP+NI6Ae9yZ0jdqvUgwESP2HJFzJL42HMo4ux4Pdw/Ixyib3GarKeM6nzEx44rV9KJTdARq6FF6B97NM7hbocu+tJKHWL7n9MVL/c+3UrsqU6J9nryBAXnVGPHK; session_id=620fc105-ca1c-4845-ab93-8db568f75271; dtCookie=6`$HERM4T5K86V5A73UQ7MLB76VPJ3VH9LK|0eed2717dafcc06d|1; gRxAlDis=N; XSRF-TOKEN=MqXsYOkK7ueMrg==.tmgDqvX4wfb8vhe6fxlYzxwBP+5Av4fK5HDLYLCHBHg=; dtSa=-; USER_LOC=5K48AZ9EjJtw8JojKNazTguAIjJ7tdA3wrem6B%2F8lpxiAGHEBxU3prS4C0KwmXiU; bm_sv=14F4A88D3F9A5ABD477796C87B185B31~52Oux41EE+L9n9lJIoq3Z7YQ6K7VnITNYAkP/1b4BzFK8+pV5gulYywmRvLvT2BRzNDY4k+vVWw+xhXIt7F86YuRq288jDDeSUV55zkFmWcCkYhgDlifZD4r+L+rPpbfEoE1wTcvgEUKbECc41kH4G30atQYrU2CyhYjVhky5FM=; ak_bmsc=64CAB467ABAEBE47FE06B0477EAF7C8117DC6B919093000013DE6D6021E24611~pllBTRwtbRqirkVAY4H7Qcaqvmivd9gfJvFsUzeZshqy3y+8uYoaDJ97GBbwM/Z91oFabXrTx7mFrNdsccX30CQF031GLsxCJ8nBBquPMu+/QiVsG/uB7JfiqLkSV76fyyuZ9lw/LyDj+Q7wVcLatMijlP2iXUwPmE/ZdH3yE0sKxIq8f5/iAWV/8C4trC1pnMqJzYtakdGYcx6hgYDfmsfqn83nG6skOTggUGpZ0V9zEvyAkR+QZ26WlwDOeDG5LsACQjD/iplFi+EDXJB69Ptw==; rxvt=1617814845220|1617813013367; dtPC=6`$213025305_183h-vDCOADFWQDUTFSPMTMUHNKDCCKTRQCGUU-0e8; _abck=F0FCE38775DFE22FACB02E7158814B78~0~YAAQkWvcF00kTIV4AQAAPgQsrQXbH16ZZoQQBjHQfwXWmGWj92Z6A4jC8PtJQGOT+t7c9v5WkNJUMtqCZCk4Dn7D8DAjqfQ4yy/g4J0dIIpFz3s5BAcmz1eTJnLzDUAjCfRXP30QeFXiz19m1vyPy57irFKcg8bueER/Hk9ynYQ/HzzmQjTrEAhPdaVrC4fan3O8rz6rj4EwA983Cs2MmtTsk08GgibBvtHc8iYduWnXUqHs2fvIYPDrraDOAGkRH6HGnF13Rly2Cor51WEghTkVgjkLYJt7tHZV+AgCaBv08U7ceYeBw1LZB2SvIkGYlUvNwq2Ln6htFUtPSlzR22WmA0t6LjUw4Cd7tUUXf7s3F/mpnCOtt8OLN83RFQHqPJ3Y4XKfymz1IugGBW3KSiaXauqAtqdGrVETtw==~-1~||1-eRrtKdMINL-1-10-1000-2||~-1; akavpau_walgreens=1617813348~id=a3418d528aa242cbb1bc0a2f8ea1c910; dtLatC=1"
		}
		ContentType = "application/json; charset=UTF-8" 
		Body        = "{`"serviceId`":`"99`",`"position`":{`"latitude`":42.5768698,`"longitude`":-71.8334145},`"appointmentAvailability`":{`"startDateTime`":`"$Tomorrow`"},`"radius`":25}"
	}
	
	## Send the request, get the response
	$WalgreensResponse = Invoke-WebRequest @WalgreensRequest

	## Parse the Walgreens Response
	$WalgreensContent = $WalgreensResponse.Content | ConvertFrom-Json

	## Test if Walgreens has appointments
	if ($WalgreensContent.appointmentsAvailable) {
		## Add the City to the LocalAppointments Array
		$LocalAppointments.Add('Walgreens:' + $WalgreensContent.availabilityGroups) | Out-Null
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
	Start-Sleep -Seconds 60

}