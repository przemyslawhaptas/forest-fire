defmodule ForestFire.SimulationServer do
  use GenServer
  require Logger

  @name {:global, __MODULE__}
  @turn_time 500

  def start_link do
    result = GenServer.start_link(__MODULE__, example_state(), name: @name)

    case result do
      {:ok, pid} ->
        Logger.info("Started #{__MODULE__}.")
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Logger.info("#{__MODULE__} already started.")
        {:ok, pid}
    end
  end

  ## API

  def start_simulation do
    GenServer.call(@name, :start_simulation)
  end

  def pause_simulation do
    GenServer.call(@name, :pause_simulation)
  end

  def stop_simulation do
    GenServer.call(@name, :stop_simulation)
  end

  def setup_board({new_board, new_board_bounds}) do
    GenServer.cast(@name, {:setup_board, {new_board, new_board_bounds}})
  end

  def get_board_setup do
    GenServer.call(@name, :get_board_setup)
  end

  def get_board do
    GenServer.call(@name, :get_board)
  end

  def get_board_bounds do
    GenServer.cast(@name, :get_board_bounds)
  end

  def get_params do
    GenServer.call(@name, :get_params)
  end

  def set_params(params) do
    GenServer.cast(@name, {:set_params, params})
  end

  def set_turn_time(milis) do
    GenServer.cast(@name, {:set_turn_time, milis})
  end

  def next_turn do
    GenServer.cast(@name, :next_turn)
  end

  ## Callbacks

  def handle_call(:start_simulation, _from, {board_setup, params, nil}) do
    {:ok, tref} = :timer.apply_interval(@turn_time, __MODULE__, :next_turn, [])
    {:reply, :simulation_started, {board_setup, params, tref}}
  end
  def handle_call(:start_simulation, _from, state) do
    {:reply, :simulation_already_started, state}
  end

  def handle_call(:pause_simulation, _from, {_board_setup, _params, nil} = state) do
    {:reply, :simulation_not_started, state}
  end
  def handle_call(:pause_simulation, _from, {board_setup, params, tref}) do
    {:ok, :cancel} = :timer.cancel(tref)
    {:reply, :simulation_paused, {board_setup, params, nil}}
  end

  def handle_call(:stop_simulation, _from, {_board_setup, _params, nil} = state) do
    {:reply, :simulation_not_started, state}
  end
  def handle_call(:stop_simulation, _from, {_board_setup, _params, tref}) do
    {:ok, :cancel} = :timer.cancel(tref)
    {:reply, :simulation_stopped, example_state()}
  end

  def handle_call(:get_board, _from, {board_setup, _params, _tref} = state) do
    {board, _board_holes, _board_bounds} = board_setup
    {:reply, board, state}
  end

  def handle_call(:get_board_bounds, _from, {board_setup, _params, _tref} = state) do
    {_board, _board_holes, board_bounds} = board_setup
    {:reply, board_bounds, state}
  end

  def handle_call(:get_params, _from, {_board_setup, params, _tref} = state) do
    {:reply, params, state}
  end

  def handle_call(:get_board_setup, _from, {board_setup, _params, _tref} = state) do
    {:reply, board_setup, state}
  end

  def handle_cast({:set_params, new_params}, {board_setup, _params, tref}) do
    {:noreply, {board_setup, new_params, tref}}
  end

  def handle_cast({:setup_board, {new_board, new_board_bounds}}, state) do
    {_board_setup, params, tref} = state

    new_board_holes = board_holes(new_board, new_board_bounds)
    new_board_setup = {new_board, new_board_holes, new_board_bounds}

    {:noreply, {new_board_setup, params, tref}}
  end

  def handle_cast({:set_turn_time, milis}, {board_setup, params, tref}) do
    if tref, do: {:ok, :cancel} = :timer.cancel(tref)
    {:ok, new_tref} = :timer.apply_interval(milis, __MODULE__, :next_turn, [])

    {:noreply, {board_setup, params, new_tref}}
  end

  def handle_cast(:next_turn, {{board, board_holes, board_bounds}, params, tref}) do
    new_board_ref = Task.Supervisor.async({ForestFire.TaskSupervisor, Node.self()},
      ForestFire.CellularAutomaton, :next_turn, [{board, params}])
    new_board_setup = {Task.await(new_board_ref), board_holes, board_bounds}

    {:noreply, {new_board_setup, params, tref}}
  end

  ## Helper functions

  def empty_state do
    ForestFire.SimulationServerUtils.empty_state
  end

  def example_state do
    ForestFire.SimulationServerUtils.example_state
  end

  def board_holes(board, bounds) do
    ForestFire.SimulationServerUtils.board_holes(board, bounds)
  end
end
