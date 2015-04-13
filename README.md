# docker-dynamic-nvidia
Dynamic Video Drivers with X-Server on Docker. (Should work with Mesa & Nvidia 304.XX, 340.XX, 346.XX, and 349.XX series drivers (All?)) 
Includes all 32 bit & 64 bit libraries as well so it should work out of the box with VirtualGL, Wine, PlayonLinux etc.

The default mode is to start up the X-Server and SSH daemon but if you start it up with any command it will just default to that and not start up any servers.

On Docker hub [dynamic-video](https://registry.hub.docker.com/u/yantis/dynamic-video/)
on Github [docker-dynamic-video](https://github.com/yantis/docker-dynamic-video)

# Description
The goal of this was a layer between [ssh-hpn-x](https://github.com/yantis/docker-ssh-hpn-x) and graphical applications.
That would just work with whatever video hardware someone had. Right now it defaults to Mesa but if it sees
that the host is using an Nvidia driver it will switch over to that one. It should support all Nvidia drivers.
This could also easily do the same for ATI but as I don't have one of those cards I am unable to test it.
You can fork this and add it yourself or if you send me SSH access to a server with an ATI card I can build it in as well.

It works well with VirtualGL. I have ran Blender as well as even Path of Exile on an Amazon EC2 GPU instance via VirtualGL and PlayOnLinux.
All in a Docker container. Checkout my Dockerfiles for these (If I didn't get around to putting them up. Just ask.)

# Tested
* Macbook Retina with Mesa drivers.

* Nvidia 349.xx OK  (Current Beta Drivers)
![](http://yantis-scripts.s3.amazonaws.com/screenshot_20150412-070107.jpg)

* Nvidia 346.xx OK  (Current Generation Drivers) (This one is an Amazon EC2 GPU instance)
![](http://yantis-scripts.s3.amazonaws.com/screenshot_20150412-071934.jpg)

* Nvidia 340.xx OK (Previous Generation Drivers)
![](http://yantis-scripts.s3.amazonaws.com/screenshot_20150412-071443.jpg)

