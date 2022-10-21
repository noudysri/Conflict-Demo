#!/bin/bash
stdDuration=4500572

startTime=$(date +%s)
startTime=$(($startTime * 1000))
startTime=$(($startTime + 180000))
echo $startTime

endTime=$(($startTime + $stdDuration))
echo $endTime

## Device id's 00008101-000C24241A20001E
filename='deviceIds.txt'
deviceIDandType=($(cat $filename|tr -d "\" \r"))
echo ------------------------------
echo Device Id Array: ${deviceIDandType[@]}
#deviceID=(00008101-000C24241A20001E)

## now loop through the deviceID array
successfulDeviceCount=0
for deviceIdandType in ${deviceIDandType[@]}
do
    echo $deviceIdandType
    deviceId=$(echo $deviceIdandType | cut -d "/" -f 1)
    echo $deviceId
    echo Allocating reservation for deviceId ${deviceId}
    content=$(curl -s "https://asda.perfectomobile.com/services/reservations?operation=create&securityToken=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI5ODJkNWFkOS1kMDI5LTRjNjQtYjFmZS02N2U3ODc4NzExNWEifQ.eyJpYXQiOjE2NTU3ODIwNDIsImp0aSI6IjFjYThhNWNiLWE1M2YtNDNjOC1hZmZlLTdkMDI2MzJmNTAwYSIsImlzcyI6Imh0dHBzOi8vYXV0aDIucGVyZmVjdG9tb2JpbGUuY29tL2F1dGgvcmVhbG1zL2FzZGEtcGVyZmVjdG9tb2JpbGUtY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRoMi5wZXJmZWN0b21vYmlsZS5jb20vYXV0aC9yZWFsbXMvYXNkYS1wZXJmZWN0b21vYmlsZS1jb20iLCJzdWIiOiJlZGI1NjliMy1kZDM4LTQ1ZWYtYTgwZi1lZjBmMmQyZjE1OGMiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoib2ZmbGluZS10b2tlbi1nZW5lcmF0b3IiLCJub25jZSI6IjdkZmQyZDkzLTQzZGYtNDhlZC04NWM0LTRhMTcyMzljMjRiMyIsInNlc3Npb25fc3RhdGUiOiJiZjQwMDY2Ni0yYzg4LTQxOWYtYjgwZi1hZTc3MmY0ZTZlMDkiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCBvZmZsaW5lX2FjY2VzcyBwcm9maWxlIn0.3gco5ObI0YMXVZ8LMSBUpkctZbgs7XgCGRF7hBWPS2c&resourceIds=$deviceId&startTime=$startTime&endTime=$endTime")
    echo $content

    substring='reservationIds'
    #Accumulates ReservationIDs
    if [[ "$content" == *"$substring"* ]]; then
        echo "Device Reseration successful"
        reservationIDS=$(jq -r '.reservationIds' <<< "${content}" )
        ReservedDevices=$(tr -d "\"[]\r" <<< "${reservationIDS}" )
        successfulReservedDevices+=($ReservedDevices)
        ((successfulDeviceCount++))
        #Accumulate DeviceID's to deallocate
        devicesToDeAllocate=$devicesToDeAllocate$deviceIdandType,
    fi
done
#Display all deviceID and Reservation ID
echo Reservation Id Array: ${successfulReservedDevices[@]}
devicesToDeAllocate=${devicesToDeAllocate%,}
echo successful DeviceId : $devicesToDeAllocate
echo count of successfulDevice : $successfulDeviceCount
# maven call  pass the deviceIDs

for key in ${successfulReservedDevices[@]}
do
  #echo reserverid is not empty
  echo Attempting deallocation the device ${key}
  URL="https://asda.perfectomobile.com/services/reservations/$key?operation=delete&securityToken=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI5ODJkNWFkOS1kMDI5LTRjNjQtYjFmZS02N2U3ODc4NzExNWEifQ.eyJpYXQiOjE2NTU3ODIwNDIsImp0aSI6IjFjYThhNWNiLWE1M2YtNDNjOC1hZmZlLTdkMDI2MzJmNTAwYSIsImlzcyI6Imh0dHBzOi8vYXV0aDIucGVyZmVjdG9tb2JpbGUuY29tL2F1dGgvcmVhbG1zL2FzZGEtcGVyZmVjdG9tb2JpbGUtY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRoMi5wZXJmZWN0b21vYmlsZS5jb20vYXV0aC9yZWFsbXMvYXNkYS1wZXJmZWN0b21vYmlsZS1jb20iLCJzdWIiOiJlZGI1NjliMy1kZDM4LTQ1ZWYtYTgwZi1lZjBmMmQyZjE1OGMiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoib2ZmbGluZS10b2tlbi1nZW5lcmF0b3IiLCJub25jZSI6IjdkZmQyZDkzLTQzZGYtNDhlZC04NWM0LTRhMTcyMzljMjRiMyIsInNlc3Npb25fc3RhdGUiOiJiZjQwMDY2Ni0yYzg4LTQxOWYtYjgwZi1hZTc3MmY0ZTZlMDkiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCBvZmZsaW5lX2FjY2VzcyBwcm9maWxlIn0.3gco5ObI0YMXVZ8LMSBUpkctZbgs7XgCGRF7hBWPS2c"
  echo $URL
  deallocateResult=$(curl -s "$URL")
  echo $deallocateResult
done
#curl -s "https://asda.perfectomobile.com/services/reservations/1095?operation=delete&securityToken=eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI5ODJkNWFkOS1kMDI5LTRjNjQtYjFmZS02N2U3ODc4NzExNWEifQ.eyJpYXQiOjE2NTU3ODIwNDIsImp0aSI6IjFjYThhNWNiLWE1M2YtNDNjOC1hZmZlLTdkMDI2MzJmNTAwYSIsImlzcyI6Imh0dHBzOi8vYXV0aDIucGVyZmVjdG9tb2JpbGUuY29tL2F1dGgvcmVhbG1zL2FzZGEtcGVyZmVjdG9tb2JpbGUtY29tIiwiYXVkIjoiaHR0cHM6Ly9hdXRoMi5wZXJmZWN0b21vYmlsZS5jb20vYXV0aC9yZWFsbXMvYXNkYS1wZXJmZWN0b21vYmlsZS1jb20iLCJzdWIiOiJlZGI1NjliMy1kZDM4LTQ1ZWYtYTgwZi1lZjBmMmQyZjE1OGMiLCJ0eXAiOiJPZmZsaW5lIiwiYXpwIjoib2ZmbGluZS10b2tlbi1nZW5lcmF0b3IiLCJub25jZSI6IjdkZmQyZDkzLTQzZGYtNDhlZC04NWM0LTRhMTcyMzljMjRiMyIsInNlc3Npb25fc3RhdGUiOiJiZjQwMDY2Ni0yYzg4LTQxOWYtYjgwZi1hZTc3MmY0ZTZlMDkiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCBvZmZsaW5lX2FjY2VzcyBwcm9maWxlIn0.3gco5ObI0YMXVZ8LMSBUpkctZbgs7XgCGRF7hBWPS2c"