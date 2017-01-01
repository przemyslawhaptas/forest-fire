defmodule ForestFire.SimulationServerUtilsSpec do
  use ESpec, async: true

  @doc """
    o - a tree
    x - a burning tree
    _ - an empty cell

    board:

     1   x _
     0   o _
      -1 0 1

   """

  let :trees, do: MapSet.new([{0, 0}])
  let :burning_trees, do: MapSet.new([{0, 1}])
  let :empty_cells, do: MapSet.new([{1, 0}, {1, 1}])

  let :board, do: {trees, burning_trees, empty_cells}
  let :board_bounds, do: {{-1, 1}, {0, 1}}

  describe "example_board/1" do
    subject(described_module().example_board({{0, 1}, {0, 0}}))

    it do: is_expected.to eq({MapSet.new([{0, 0}, {1, 0}]), %MapSet{}, %MapSet{}})
  end

  describe "board_holes/2" do
    subject(described_module().board_holes(board, board_bounds))

    let :holes, do: MapSet.new([{-1, 0}, {-1, 1}])

    it do: is_expected.to eq(holes)
  end
end
