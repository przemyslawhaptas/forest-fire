defmodule ForestFire.ConsolePrinterSpec do
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

    it do: is_expected.to eq(marked_board_cells)
  end

  describe "mark_board_holes_cells/1" do
    let :board_holes, do: MapSet.new([{-1, 0}, {-1, 1}])

    subject(described_module().mark_board_holes_cells(board_holes))

    it do: is_expected.to eq(marked_board_holes_cells)
  end

  describe "build_printable_board/2" do
    subject(described_module().build_printable_board(marked_board_cells, marked_board_holes_cells))

    let :printable_board, do: ["\e[0m  ", "\e[41m* ", "\e[47m  ", "\e[0m  ", "\e[42mO ", "\e[47m  "]

    it do: is_expected.to eq(printable_board)
  end

  describe "compare_cords/2" do
    it do: expect(described_module().compare_cords({0, 1}, {0, 0})).to eq(true)
    it do: expect(described_module().compare_cords({0, 1}, {1, 1})).to eq(true)

    it do
      expect(described_module().compare_cords({1, 1}, {0, 1})).to eq(false)
      expect(described_module().compare_cords({0, 0}, {0, 1})).to eq(false)
    end
  end

  describe "sort_marked_cells/1" do
    subject(described_module().sort_marked_cells(marked_cells))

    let :marked_cells, do: MapSet.union(marked_board_cells, marked_board_holes_cells)
    let :sorted_marked_cells, do: [
      {{-1, 1}, "\e[0m  "}, {{0, 1}, "\e[41m* "}, {{1, 1}, "\e[47m  "},
      {{-1, 0}, "\e[0m  "}, {{0, 0}, "\e[42mO "}, {{1, 0}, "\e[47m  "}
    ]

    it do: is_expected.to eq(sorted_marked_cells)
  end
end
