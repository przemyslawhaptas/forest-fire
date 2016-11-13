defmodule ForestFire.CellularAutomatonSpec do
  use ESpec, async: true
  @doc """
    o - a tree
    * - a burning tree
    _ - an empty cell

    board:

    1     _ _
    0   * * _
   -1   o o *
   -2     o

       -1 0 1
  """

  let :trees, do:         [{ -1, -1 }, { 0, -2 }, { 0, -1 }, { 1, 2 }]
  let :burning_trees, do: [{ -1, 0 }, { 0, 0 }, { 1, -1 }]
  let :empty_cells, do: [{ 0, 1 }, { 1, 0 }, { 1, 1 }]
  let :board, do: { trees, burning_trees, empty_cells }

  let :p_lightning_prob, do: 100
  let :f_growth_prob, do: 100
  let :params, do: { p_lightning_prob, f_growth_prob }

  describe "burn_trees_down/1" do
    subject(described_module().burn_trees_down(board))

    it do: is_expected.to eq(
      { trees,
        [],
        [{ -1, 0 }, { 0, 0 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 }] |> Enum.sort })
  end

  describe "spread_fire/1" do
    subject(described_module().spread_fire(board))

    let :trees_after, do: [{ 1, 2 }]
    let :burning_trees_after, do:
      [{ -1, -1 }, { 0, -2 }, { 0, -1 }, { -1, 0 }, { 0, 0 }, { 1, -1 }]

    it do
      { t, b_t, e_c } = subject
      
      expect({ t |> Enum.sort, b_t |> Enum.sort, e_c })
        .to eq({ trees_after |> Enum.sort, burning_trees_after |> Enum.sort, empty_cells })
    end
  end

  describe "adjacent_cells/1" do
    describe "when argument is a cell" do
      subject(described_module().adjacent_cells({ 0, 0 }) |> Enum.sort)

      it do: is_expected.to eq([
        { -1, -1 }, { -1, 0 }, { -1, 1 },
        { 0, -1 }, { 0, 1 },
        { 1, -1 }, { 1, 0 }, { 1, 1 }]
        |> Enum.sort)
    end
    describe "when argument is a list of cells" do
      subject(described_module().adjacent_cells([{ 0, 0 }, { 1, 0 }]) |> Enum.sort)

      it do: is_expected.to eq([
        { -1, -1 }, { -1, 0 }, { -1, 1 },
        { 0, -1 }, { 0, 1 },
        { 1, -1 }, { 1, 1 },
        { 2, -1 }, { 2, 0 }, { 2, 1 }]
        |> Enum.sort)
    end
  end

  describe "affected_trees/1" do
    subject(described_module().affected_trees(cells_in_fire_range, trees) |> Enum.sort)

    let :cells_in_fire_range, do: [{ -1, -1 }, { 0, -2 }, { -1, 0 }, { 1, 1 }]
    it do: is_expected.to eq([{ -1, -1 }, { 0, -2 }] |> Enum.sort)
  end
end
