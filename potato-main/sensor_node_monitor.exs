#! /home/solaris/.asdf/shims/elixir

# Crash Catcher on Sensor Node for GUSC (MSci Project 2024)
iex --name "bob@10.42.0.1" --cookie "secret" -S mix
{pid, ref} = spawn_monitor(Server, :run, [])
flush
Process.sleep(3200)
flush
