defmodule Triplex.Unification do
  alias Triplex.Variable

  def solve(predicates, statements) do
    solve(predicates, statements, %{})
  end
  def solve([], _statements, prev_result) do
    [prev_result]
  end
  def solve(predicates, statements, prev_result) do
    [first_predicate | tail_predicates] = predicates

    # apply substitution
    first_predicate = first_predicate
    |> Tuple.to_list()
    |> Enum.map(
      fn (item) ->
        if Variable.is?(item) and Map.has_key?(prev_result, item.name) do
          Map.get(prev_result, item.name)
        else
          item
        end
      end
    )
    |> List.to_tuple()

    unify(first_predicate, statements)
    |> Enum.map(&Map.merge(prev_result, &1))
    |> Enum.map(&solve(tail_predicates, statements, &1))
    |> List.flatten()
  end

  def unify(predicate, statements)
    when
      is_tuple(predicate) and is_list(statements)
    do
    Enum.reduce(
      statements,
      [],
      fn (statement, result) ->
        unification = unify(statement, predicate)
        if unification != nil do
          [unification | result]
        else
          result
        end
      end
    )
  end

  @doc ~S"""

    iex> x = Triplex.Variable.new(:x)
    %Triplex.Variable{name: :x}
    iex> y = Triplex.Variable.new(:y)
    %Triplex.Variable{name: :y}
    # Can solve simple case
    iex> Triplex.Unification.unify(x, 1)
    %{x: 1}
    # Mismatch causes fail
    iex> Triplex.Unification.unify({y, x, 1}, {1, 2, 2})
    nil

  """

  def unify(u, v) do
    s = unify(u, v, %{})
    if s == nil do
      nil
    else
      s
      |> Map.to_list()
      |> Enum.map(fn ({key, value}) -> {key.name, value} end)
      |> Map.new()
    end
  end

  def unify(u, v, s) do
    u = transive_get(s, u)
    v = transive_get(s, v)
    cond do
      Variable.is?(u) -> Map.put s, u, v
      Variable.is?(v) -> Map.put s, v, u
      u == v -> s
      true -> _unify u, v, s
    end
  end

  @doc ~S"""
  Unify tuples

    iex> x = Triplex.Variable.new(:x)
    %Triplex.Variable{name: :x}
    iex> y = Triplex.Variable.new(:y)
    %Triplex.Variable{name: :y}
    # Can solve simple tuples
    iex> Triplex.Unification.unify({1, x}, {1, 2})
    %{x: 2}
    # Can solve tuples with multiple vars
    iex> Triplex.Unification.unify({y, x}, {1, 2})
    %{y: 1, x: 2}
    # Irregular size causes fail
    iex> Triplex.Unification.unify({1, x, 2}, {1, 2})
    nil
    # Can solve maps
    iex> Triplex.Unification.unify(%{g: x, l: 1}, %{g: 12, l: 1})
    %{x: 12}
    iex> Triplex.Unification.unify(%{g: x, l: y}, %{g: 12, l: 1})
    %{x: 12, y: 1}
    iex> Triplex.Unification.unify({1, x}, %{g: 12, l: 1})
    nil

  """

  def _unify(u, v, s)
    when
      is_tuple(u) and
      is_tuple(v) and
      tuple_size(u) == tuple_size(v)
    do
    [u, v]
    |> List.zip()
    |> Enum.reduce_while(
      s,
      fn ({u, v}, s) ->
        s = unify(u, v, s)
        if s == nil, do: {:halt, nil}, else: {:cont, s}
      end
    )
  end

  def _unify(u, v, s)
    when
      is_map(u) and
      is_map(v) and
      map_size(u) == map_size(v)
    do
    u
    |> Map.to_list()
    |> Enum.reduce_while(
      s,
      fn ({key, u_val}, s) ->
        if Map.has_key?(v, key) do
          s = unify(u_val, Map.get(v, key), s)
          if s == nil, do: {:halt, nil}, else: {:cont, s}
        else
          {:halt, nil}
        end
      end
    )
  end

  def _unify(_, _, _) do
    nil
  end

  @doc ~S"""
  Transitive Map.get

  # Example

    iex> d = %{1 => 2, 2 => 3, 3 => 4}
    iex> Triplex.Unification.transive_get d, 1
    4

  """
  def transive_get(map, key)  do
    if not is_map(key) and Map.has_key?(map, key) do
      transive_get(map, Map.get(map, key))
    else
      key
    end
  end

end
