defmodule ForestFire.Utils do
  def example_board({{x_min, x_max}, {y_min, y_max}} \\ {{-9, 9}, {-9, 9}}) do
    trees = for x <- x_min .. x_max, y <- y_min .. y_max,
      do: {x, y}, into: %MapSet{}

    { trees, %MapSet{}, %MapSet{} }
  end
end
