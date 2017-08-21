defmodule TriplexTest.UnificationWithFilters do
  use ExUnit.Case, async: false
  alias Triplex.Unification
  import Triplex.Variable, only: [v: 1]

  doctest Triplex.Unification

  setup do
    %{
      query: [
        {v(:person), :age, v(:age)},
        fn (%{age: age}) -> age > 15 end,
        {v(:person), :type, :person},
        {v(:person), :name, v(:name)},
      ],
      dataset: [
        {12, :type, :person},
        {12, :name, "pepe"},
        {12, :age, 10},

        {11, :type, :person},
        {11, :name, "alex"},
        {11, :age, 14},

        {10, :type, :person},
        {10, :name, "juan"},
        {10, :age, 18},

        {9, :type, :person},
        {9, :name, "juana"},
        {9, :age, 23},
      ],
    }
  end

  test "unify with filtering functions", %{query: query, dataset: dataset} do
    unification = Unification.solve(query, dataset)
    assert unification == [
      %{age: 23, name: "juana", person: 9},
      %{age: 18, name: "juan", person: 10}
    ]
  end

end

