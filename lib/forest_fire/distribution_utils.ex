defmodule ForestFire.DistributionUtils do
  def async(module \\ ForestFire.CellularAutomaton, fun_sym, args) do
    Task.Supervisor.async({ForestFire.TaskSupervisor, Node.self()},
      module, fun_sym, args)
  end
  def async(fun) do
    Task.Supervisor.async({ForestFire.TaskSupervisor, Node.self()}, fun)
  end
end
