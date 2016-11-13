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

  let :trees, do:         MapSet.new([{ -1, -1 }, { 0, -2 }, { 0, -1 }, { 1, 2 }])
  let :burning_trees, do: MapSet.new([{ -1, 0 }, { 0, 0 }, { 1, -1 }])
  let :empty_cells, do:   MapSet.new([{ 0, 1 }, { 1, 0 }, { 1, 1 }])

  let :board, do: { trees, burning_trees, empty_cells }

  describe "burn_trees_down/1" do
    subject(described_module().burn_trees_down(board))

    it do: is_expected.to eq(
      { trees,
        %MapSet{},
        MapSet.new([{ -1, 0 }, { 0, 0 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 }]) })
  end

  describe "spread_fire/1" do
    subject(described_module().spread_fire(board))

    let :unaffected_trees, do: MapSet.new([{ 1, 2 }])
    let :all_burning_trees, do: MapSet.new(
      [{ -1, -1 }, { 0, -2 }, { 0, -1 }, { -1, 0 }, { 0, 0 }, { 1, -1 }])

    it do: is_expected.to eq({ unaffected_trees, all_burning_trees, empty_cells })
  end

  describe "adjacent_cells/1" do
    describe "when argument is a set of cells" do
      subject(described_module().adjacent_cells(MapSet.new([{ 0, 0 }, { 1, 0 }])))

      it do: is_expected.to eq(MapSet.new([
        { -1, -1 }, { -1, 0 }, { -1, 1 },
        { 0, -1 }, { 0, 1 },
        { 1, -1 }, { 1, 1 },
        { 2, -1 }, { 2, 0 }, { 2, 1 }]))
    end
    describe "when argument is a cell" do
      subject(described_module().adjacent_cells({ 0, 0 }))

      it do: is_expected.to eq(MapSet.new([
        { -1, -1 }, { -1, 0 }, { -1, 1 },
        { 0, -1 }, { 0, 1 },
        { 1, -1 }, { 1, 0 }, { 1, 1 }]))
    end
  end

  describe "strike_lightnings/2" do
    describe "when there is 100% chance of lightning strike" do
      subject(described_module()
        .strike_lightnings({ trees, burning_trees, empty_cells }, p_lightning_prob))

      let :p_lightning_prob, do: 100

      it do: is_expected.to eq(
        { %MapSet{},
          MapSet.union(burning_trees, trees),
          empty_cells })
    end

    describe "when there is 0% chance of lightning strike" do
      subject(described_module().strike_lightnings(board, p_lightning_prob))

      let :p_lightning_prob, do: 0

      it do: is_expected.to eq(board)
    end
  end

  describe "grow_trees/2" do
    describe "when there is 100% chance of growing a tree" do
      subject(described_module()
        .grow_trees({ trees, burning_trees, empty_cells }, f_growth_prob))

      let :f_growth_prob, do: 100

      it do: is_expected.to eq(
        { MapSet.union(trees, empty_cells),
          burning_trees,
          %MapSet{} })
    end

    describe "when there is 0% chance of growing a tree" do
      subject(described_module().grow_trees(board, f_growth_prob))

      let :f_growth_prob, do: 0

      it do: is_expected.to eq(board)
    end
  end
end
