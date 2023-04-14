# Dockerized ClamAV Private Mirror
This is a dockerized database mirror for the Clam Antivirus. 

While by default using official mirrors ClamAV allows the configuration of a `PrivateMirror` or `DatabaseMirror` to be a custom hostname or IP address under your management.

The official mirrors are of course the most accurate and probably the fastest way of upding the local database, however they tend to rate limit your IP address after multiple updating processes in some timewindow (through updater tool `FreshClam`). 
This becomes more of a problem when you have more than one ClamAV host with periodic updates.

In this case, it is better to host your own private mirror of the Clam Antivirus Database. 
The private mirror which is this dockerized project, updates its database every couple (configurable) hours and all ClamAV hosts in the local network should be configured to now pull the database from the private mirror instead of the offical ones.

## Instructions

```bash
# Then run the mirror on port 80
sudo docker run --rm --name clamav_mirror -p 80:80 chmey/clamav-mirror:latest
``` 

In the freshclam.conf on ClamAV hosts, set:
```
DatabaseMirror http://my-dockerized-clamav-mirror
```

while replacing the hostname with the IP or hostname of your database mirror host.

## Third Party
For updating the dataase, the Python tool `cvdupdate` developed by Micah Snyder (co-dev of ClamAV) is used.

* [cvdupdate](https://github.com/micahsnyder/cvdupdate/blob/main/LICENSE): This tool downloads the latest ClamAV databases along with the latest database patch files.

## Configuration
So far the only possible configuration is to rebuild the image with changed parameters in `mirror.py`.

Environment variables will soon be available for configuration of the mirror.


