defmodule TriplexTest.MapsUnification do
  use ExUnit.Case, async: false
  alias Triplex.Unification
  import Triplex.Variable, only: [v: 1]

  doctest Triplex.Unification

  setup do
    %{
      query: [
        %{id: v(:person), type: :person},
        %{id: v(:post), type: :post, author: v(:person), content: v(:content)},
      ],
      dataset: [
        %{id: 12, type: :person, name: "juan", age: 23},

        %{id: 1, type: :post, author: 12, content: "Post number 1"},
        %{id: 2, type: :post, author: 12, content: "Post number 2"},

        %{
            id: 3,
            type: :comment,
            post: 1,
            author: 12,
            content: "Comment for post 1"
        },
      ],
    }
  end

  test "unify predicate against maps" do
    unification = Unification.unify(
      %{name: v(:name), age: 1},
      [
        %{name: "alex", age: 2},
        %{name: "juan", age: 1},
        %{name: "han", age: 1},
      ]
    )
    assert unification == [%{name: "han"}, %{name: "juan"}]
  end

  test "solve map predicate", %{query: query, dataset: dataset} do
    results = Unification.solve(query, dataset)
    assert results == [
      %{content: "Post number 2", person: 12, post: 2},
      %{content: "Post number 1", person: 12, post: 1}
    ]
  end

  test "solving a map query is idempotent", %{query: query, dataset: dataset} do
    for _ <- 1..5 do
      results = query
        |> Enum.shuffle
        |> Unification.solve(dataset)
      assert results == [
        %{content: "Post number 2", person: 12, post: 2},
        %{content: "Post number 1", person: 12, post: 1}
      ]
    end
  end
end

