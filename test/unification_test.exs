defmodule TriplexTest.Unification do
  use ExUnit.Case, async: true
  doctest Triplex.Unification
  alias Triplex.{Unification, Variable}

  setup do
    %{
      name: Variable.new(:name),
      person: Variable.new(:person),
      post: Variable.new(:post),
      content: Variable.new(:content),
    }
  end

  test "unify predicate against statements", %{name: name} do
    unification = Unification.unify(
      {name, :age, 1},
      [
        {"alex", :age, 2},
        {"juan", :age, 1},
        {"han", :age, 1},
      ]
    )
    assert unification == [%{name: "han"}, %{name: "juan"}]
  end

  test "solve predicate", %{person: person, post: post, content: content} do
    results = Unification.solve(
      [
        {person, :type, :person},
        {post, :type, :post},
        {post, :author, person},
        {post, :content, content},
      ],
      [
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
      ]
    )
    assert results == [
      %{content: 'Post number 2', person: 12, post: 2},
      %{content: 'Post number 1', person: 12, post: 1}
    ]
  end

end

