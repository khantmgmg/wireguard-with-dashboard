# wireguard-with-dashboard

docker hub: https://hub.docker.com/r/khantmg/wg-ui

docker run -d --name wg-ui --privileged -p 51820:51820/udp -p 10086:10086 khantmg/wg-ui:latest

"http://public-ip-address:10086⁠" to access the wireguard dashboard. Default username and password will be "admin:admin"

After logging into the dashboard, in the settings page, update the Peer Remote Endpoint to the public ip of the server.

Add new peer by going to "wg0" under configurations and click "Add peer".

Fill the name and Allowed IPs in the form and save.

Allowed IPs: If the wireguard server ip is 10.0.0.1, the allowed IP should be 10.0.0.xxx.
