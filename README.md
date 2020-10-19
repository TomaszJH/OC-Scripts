# OC-Reactor-Control-Script
A Reactor Control script used in conjunction with OpenComputers and Draconic Evolution Reactors

This script is designed to be compatible with the 1.12.2 version of the mod as well as backwards compatible with 1.7.10 version of this mod

Please refer to the wiring diagram included with this repository to configure the panels correctly.

# Screenshots
![Alt-Text](/screenshots/screenshot001.png?raw=true)

# Setup Guide
1) Download this script from this repository. I reccommend to use wget inculded with the mod.
2) Connect adapters to:
  -1 Reactor Stabilizer
  -Input Gate
  -Output Gate
  -Energy Pylon
3) Connect 2 Redstone interfaces. Follow wiring guide on how to assemble and connect panels
4) Edit reactorcont.lua. Replace UUIDs located in the file with custom UUIDs of your devices.
5) Execute ./reactorcont.lua. If something does not work, check all connections and try again.

 # End Notes
 I have written this script entirely on my own. Feel free to use it and modify it to fit personal needs. 
