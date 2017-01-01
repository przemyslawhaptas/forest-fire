defmodule ForestFire.SimulationServerUtils do
  def board_holes(board, {{x_min, x_max}, {y_min, y_max}}) do
    all_cells = for x <- x_min .. x_max, y <- y_min .. y_max,
      do: {x, y}, into: %MapSet{}

    {trees, burning_trees, empty_cells} = board

    all_cells
    |> MapSet.difference(trees)
    |> MapSet.difference(burning_trees)
    |> MapSet.difference(empty_cells)
  end

  def empty_state do
    board_bounds = {{0, 0}, {0, 0}}
    empty_board = {%MapSet{}, %MapSet{}, %MapSet{}}
    board_holes = %MapSet{}

    empty_params = {0, 0}
    tref = nil

    {{empty_board, board_holes, board_bounds}, empty_params, tref}
  end

  def example_state do
    board_bounds = example_board_bounds
    board = example_board(example_board_bounds)
    board_holes = board_holes(board, board_bounds)
    params = example_params
    tref = nil

    {{board, board_holes, board_bounds}, params, tref}
  end

  def example_board({{x_min, x_max}, {y_min, y_max}}) do
    trees = for x <- x_min .. x_max, y <- y_min .. y_max,
      do: {x, y}, into: %MapSet{}

    {trees, %MapSet{}, %MapSet{}}
  end

  def example_board_bounds do
    {{-50, 50}, {-30, 30}}
  end

  def example_params do
    p_lightning_prob = 0.05
    f_growth_prob = 4.2
    {p_lightning_prob, f_growth_prob}
  end
end
