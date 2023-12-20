# Potato Smart Campus

An implementation of the University of Glasgow Smart Campus using the Potato library for Elixir.
Made as part of my MSci project.

## How to run the website

1. Run `cd smart_campus`
2. Run `mix deps.get` to install dependencies
3. Run `mix phx.server` to start the server
4. View at: http://localhost:4000/sensors

## How to run the program (on windows)

1. Run `cd potato-main`
2. Run `wsl`
3. Login to your user account (with root perms) using `su username`, replacing "username" with your username
4. Run `sudo mix deps.get` to install dependencies
5. Run `sudo iex --name bob@ipaddr --cookie "secret" -S mix` and `sudo iex --name alice@ipaddr --cookie "secret" -S mix` on separate terminals to start the potato program - replace "ipaddr" with the ip address of the node
6. Run `Server.run()` and `SensorNode.run()` on separate terminals to start the server and sensor node nodes
