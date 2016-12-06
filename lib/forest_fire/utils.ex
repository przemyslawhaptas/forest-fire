defmodule ForestFire.Utils do
  def start_simulation_server_with_example_state do
    bounds = example_board_bounds()
    ForestFire.SimulationServer.setup_board({example_board(bounds), bounds})

    example_params()
    |> ForestFire.SimulationServer.set_params()

    ForestFire.SimulationServer.start_simulation()
  end

  def example_board({{x_min, x_max}, {y_min, y_max}}) do
    trees = for x <- x_min .. x_max, y <- y_min .. y_max,
      do: {x, y}, into: %MapSet{}

    {trees, %MapSet{}, %MapSet{}}
  end

  def example_board_bounds do
    {{-30, 30}, {-30, 30}}
  end

  def example_params do
    p_lightning_prob = 0.05
    f_growth_prob = 4
    {p_lightning_prob, f_growth_prob}
  end

  def board_holes(board, {{x_min, x_max}, {y_min, y_max}}) do
    all_cells = for x <- x_min .. x_max, y <- y_min .. y_max,
      do: {x, y}, into: %MapSet{}

    {trees, burning_trees, empty_cells} = board

    all_cells
    |> MapSet.difference(trees)
    |> MapSet.difference(burning_trees)
    |> MapSet.difference(empty_cells)
  end
end
