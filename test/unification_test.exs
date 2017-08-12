defmodule TriplexTest.Unification do
  use ExUnit.Case, async: true
  alias Triplex.Unification
  import Triplex.Variable, only: [v: 1]

  doctest Triplex.Unification

  setup do
    %{
      query: [
        {v(:person), :type, :person},
        {v(:post), :type, :post},
        {v(:post), :author, v(:person)},
        {v(:post), :content, v(:content)},
      ],
      dataset: [
        {12, :type, :person},
        {12, :name, 'juan'},
        {12, :age, 23},

        {1, :type, :post},
        {1, :author, 12},
        {1, :content, 'Post number 1'},

        {2, :type, :post},
        {2, :author, 12},
        {2, :content, 'Post number 2'},

        {3, :type, :comment},
        {3, :post, 1},
        {3, :author, 12},
        {3, :content, 'Comment for post 1'},
      ],
    }
  end

  test "unify predicate against statements" do
    unification = Unification.unify(
      {v(:name), :age, 1},
      [
        {"alex", :age, 2},
        {"juan", :age, 1},
        {"han", :age, 1},
      ]
    )
    assert unification == [%{name: "han"}, %{name: "juan"}]
  end

  test "solve predicate", %{query: query, dataset: dataset} do
    results = Unification.solve(query, dataset)
    assert results == [
      %{content: 'Post number 2', person: 12, post: 2},
      %{content: 'Post number 1', person: 12, post: 1}
    ]
  end

  test "solving a query is idempotent", %{query: query, dataset: dataset} do
    for _ <- 1..5 do
      results = query
        |> Enum.shuffle
        |> Unification.solve(dataset)
      assert results == [
        %{content: 'Post number 2', person: 12, post: 2},
        %{content: 'Post number 1', person: 12, post: 1}
      ]
    end
  end

end

