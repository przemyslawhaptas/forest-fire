defmodule ForestFire.DistributionUtilsSpec do
  use ESpec

  before do: allow(described_module()).to accept(
    :available_nodes, fn () -> Node.self end)

  describe "random_node/0" do
    subject(described_module().random_node())

    it do: is_expected.to eq(Node.self)
  end

  describe "pick_node/1" do
    subject(described_module().pick_node(&described_module().random_node/0))

    it do: is_expected.to eq(described_module().random_node())
  end
end
