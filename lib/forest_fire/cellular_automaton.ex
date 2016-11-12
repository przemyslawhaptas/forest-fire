defmodule ForestFire.CellularAutomaton do
  # @automaton_size 10
  # @p_lightning_prob 5
  # @f_growth_prob 40

  def next_turn({ board, params }) do
    board1 = burn_trees_down(board)
    board2 = spread_fire(board)
    board3 = strike_a_lightning({ board, params })
    board4 = grow_trees({ board, params })

    new_board([board1, board2, board3, board4])
  end

  def burn_trees_down({ trees, burning_trees, empty_cells }) do
    { trees, [],  (empty_cells ++ burning_trees) |> Enum.sort }
  end

  def spread_fire(state) do
    state
  end

  def strike_a_lightning(state) do
    state
  end

  def grow_trees(state) do
    state
  end

  def init do

  end

  def new_board(_boards) do

  end
end
