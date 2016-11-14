defmodule ForestFire.ConsolePrinterSpec do
  use ESpec, async: true

  @doc """
    o - a tree
    * - a burning tree
    _ - an empty cell

    board:

     1   * _
     0   o _
    -1

      -1 0 1

   """


  let :trees, do: MapSet.new([{ 0, 0 }])
  let :burning_trees, do: MapSet.new([{ 0, 1 }])
  let :empty_cells, do: MapSet.new([{ 1, 0 }, { 1, 1 }])

  let :board, do: { trees, burning_trees, empty_cells }
  let :board_map, do: %{
    { 0, 0 } => 'o',
    { 0, 1 } => '*',
    { 1, 0 } => '_',
    { 1, 1 } => '_'
  }

  describe "transform_into_map/1" do
    let :trees, do: MapSet.new([{ 0, 0 }])
    let :burning_trees, do: MapSet.new([{ 0, 1 }])
    let :empty_cells, do: MapSet.new([{ 1, 0 }, { 1, 1 }])

    subject(described_module().transform_into_map({ trees, burning_trees, empty_cells }))

    it do: is_expected.to eq(board_map)
  end

  describe "get_cells_mark/2" do
    subject(described_module().get_cells_mark(board_map, coords))

    describe "when the cell belongs to the board" do
      let :coords, do: { 0, 0 }
      it do: is_expected.to eq('o')
    end

    describe "when the cell doesn't belong to the board" do
      let :coords, do: { -100, 0 }
      it do: is_expected.to eq(' ')
    end
  end

  describe "build_line/3" do
    subject(described_module().build_line(0, { -1, 1 }, board_map))

    it do: is_expected.to eq(" 0   o _\n")
  end

  describe "build_lines/2" do
    subject(described_module().build_lines({ { -1, 1 }, { -1, 1 } }, board_map))

    it do: is_expected.to eq([
      " 1   * _\n",
      " 0   o _\n",
      "-1 \n",
      "  -1 0 1\n" ])
  end
end
