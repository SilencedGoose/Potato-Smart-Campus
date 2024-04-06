# Crash Catcher on Sensor Node for GUSC (MSci Project 2024)
defmodule CC do
    def crash_catcher() do
        spawn_monitor(SensorNode, :run, [])                             # SNS
        _exit_code = receive do                                         # SNS
            {:DOWN, _, :process, _, exit_code} -> exit_code             # SNS
        end
        #IO.inspect("Exited with exit code: " <> to_string(exit_code))
        Process.sleep(12000)
        crash_catcher()                                                 # SNS
    end
end

CC.crash_catcher()                                                      # SNS
