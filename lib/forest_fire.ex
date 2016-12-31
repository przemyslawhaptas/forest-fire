defmodule ForestFire do
  use Application
  require Logger

  def start(type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: ForestFire.TaskSupervisor]]),
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

    opts = [strategy: :one_for_one, name: {:global, ForestFire.Supervisor}]

    Supervisor.start_link(children, opts)
  end

  def start_simulation do
    ForestFire.SimulationServer.start_simulation()
  end

  def pause_simulation do
    ForestFire.SimulationServer.pause_simulation()
  end

  def stop_simulation do
    ForestFire.SimulationServer.stop_simulation()
  end

  def start_visualization do
    ForestFire.VisualizationAgent.start_visualization()
  end

  def stop_visualization do
    ForestFire.VisualizationAgent.stop_visualization()
  end
end
