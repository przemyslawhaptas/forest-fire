defmodule ForestFire.SimulationServerSpec do
  use ESpec, async: true

  let :marked_board_cells, do: MapSet.new([
    {{0, 0}, "\e[42mO "},
    {{0, 1}, "\e[41m* "},
    {{1, 0}, "\e[47m  "},
    {{1, 1}, "\e[47m  "}
  ])

  let :marked_board_holes_cells, do: MapSet.new([
    {{-1, 0}, "\e[0m  "},
    {{-1, 1}, "\e[0m  "}
  ])

  describe "mark_board_cells/1" do
    let :trees, do: MapSet.new([{0, 0}])
    let :burning_trees, do: MapSet.new([{0, 1}])
    let :empty_cells, do: MapSet.new([{1, 0}, {1, 1}])

    let :board, do: {trees, burning_trees, empty_cells}
    let :board_bounds, do: {{-1, 1}, {0, 1}}

    subject(described_module().mark_board_cells(board))

    xit do: is_expected.to eq(marked_board_cells)
  end
end
