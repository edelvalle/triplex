defmodule TriplexTest.RegistryTest do
  use ExUnit.Case, async: true
  doctest Triplex.Unification

  setup do
    {:ok, registry} = start_supervised Triplex
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    Triplex.add(registry, {1, :type, :person})

    assert Triplex.solve(registry, 1) == [1]
  end
end
