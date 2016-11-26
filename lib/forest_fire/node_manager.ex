defmodule ForestFire.NodeManager do
  def pick_node(strategy \\ &random_node/0) do
    strategy.()
  end

  def random_node do
    Enum.random(available_nodes())
  end

  defp available_nodes do
    [ Node.self | Node.list ]
  end
end
