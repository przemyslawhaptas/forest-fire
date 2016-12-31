defmodule ForestFire do
  use Application
  require Logger

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Task.Supervisor, [[name: ForestFire.TaskSupervisor]]),
      # Starts a worker by calling: ForestFire.Worker.start_link(arg1, arg2, arg3)
      worker(ForestFire.VisualizationAgent, []),
      worker(ForestFire.SimulationServer, [])
    ]

    case type do
      :normal ->
        Logger.info("Application is started on #{node()}")
      {:takeover, old_node} ->
        Logger.info("#{node()} is taking over #{old_node}")
      {:failover, old_node} ->
        Logger.info("#{old_node} is failing over to #{node()}")
    end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: {:global, ForestFire.Supervisor}]

    Supervisor.start_link(children, opts)
  end
end
