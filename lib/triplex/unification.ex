defmodule Triplex.Unification do
  alias Triplex.Variable

  def solve(predicates, statements) do
    solve(predicates, statements, %{})
  end
  def solve([], _statements, prev_result) do
    [prev_result]
  end
  def solve([first_predicate | tail_predicates], statements, prev_result) do
    first_predicate
    |> apply_substitution(prev_result)
    |> unify(statements)
    |> Enum.map(&Map.merge(prev_result, &1))
    |> Enum.map(&solve(tail_predicates, statements, &1))
    |> List.flatten()
  end

  defp apply_substitution(predicate, results) when is_tuple(predicate) do
    predicate
    |> Tuple.to_list()
    |> Enum.map(&substitute_a_value(&1, results))
    |> List.to_tuple()
  end
  defp apply_substitution(predicate, results) when is_map(predicate) do
    predicate
    |> Map.to_list()
    |> Enum.map(&substitute_a_value(&1, results))
    |> Map.new()
  end

  defp substitute_a_value(item, results) do
    if Variable.is?(item) and Map.has_key?(results, item.name) do
      Map.get(results, item.name)
    else
      item
    end
  end

  def unify(predicate, statements) when is_list(statements) do
    Enum.reduce(
      statements,
      [],
      fn (statement, result) ->
        unification = unify(predicate, statement)
        if unification != nil do
          [unification | result]
        else
          result
        end
      end
    )
  end

  @doc ~S"""

    iex> x = Triplex.Variable.v(:x)
    %Triplex.Variable{name: :x}
    iex> y = Triplex.Variable.v(:y)
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
    u = Map.get(s, u, u)
    v = Map.get(s, v, v)
    cond do
      u == v -> s
      Variable.is?(u) -> Map.put s, u, v
      Variable.is?(v) -> Map.put s, v, u
      true -> _unify u, v, s
    end
  end

  @doc ~S"""
  Unify tuples

    iex> x = Triplex.Variable.v(:x)
    %Triplex.Variable{name: :x}
    iex> y = Triplex.Variable.v(:y)
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

  def _unify(u, v, s) when is_map(u) and is_map(v) do
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

end
