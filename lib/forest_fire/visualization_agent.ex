defmodule ForestFire.VisualizationAgent do
  require Logger

  @visualization_rate 1000
  @name {:global, __MODULE__}

  def start_link do
    result = Agent.start_link(fn -> nil end, name: @name)

    case result do
      {:ok, pid} ->
        Logger.info("Started #{__MODULE__}.")
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Logger.info("#{__MODULE__} already started.")
        {:ok, pid}
    end
  end

  def start_visualization do
    Agent.get_and_update(@name, __MODULE__, :do_start_visualization, [])
  end

  def do_start_visualization(nil) do
    {:ok, tref} = :timer.apply_interval(@visualization_rate, __MODULE__, :visualize, [])
    {:visualization_started, tref}
  end
  def do_start_visualization(tref), do: {:visualization_already_started, tref}

  def visualize do
    {board, board_holes, board_bounds} = ForestFire.SimulationServer.get_board_setup()
    ForestFire.ConsolePrinter.print(board, board_holes, board_bounds)
  end

  def stop_visualization do
    Agent.get_and_update(@name, __MODULE__, :do_stop_visualization, [])
  end

  def do_stop_visualization(nil), do: {:visualization_not_started, nil}
  def do_stop_visualization(tref) do
    {:ok, :cancel} = :timer.cancel(tref)
    {:visualization_stopped, nil}
  end
end
