defmodule ForestFire.CellularAutomatonSpec do
  use ESpec, async: true

  let :trees, do:         [{ -1, -1 }, { 0, -2 }, { 0, -1 }, { 1, 2 }]
  let :burning_trees, do: [{ -1, 0 }, { 0, 0 }, { 1, -1 }]
  let :empty_cells, do: [{ 0, 1 }, { 1, 0 }, { 1, 1 }]
  let :board, do: { trees, burning_trees, empty_cells }

  let :p_lightning_prob, do: 100
  let :f_growth_prob, do: 100
  let :params, do: { p_lightning_prob, f_growth_prob }

  describe "burn_trees_down" do
    subject(described_module().burn_trees_down(board))

    it do: is_expected.to eq(
      { trees, [], [{ -1, 0 }, { 0, 0 }, { 0, 1 }, { 1, -1 }, { 1, 0 }, { 1, 1 }] })
  end
end
