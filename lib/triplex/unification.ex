defmodule Triplex.Unification do
  alias Triplex.Variable

  def solve(predicates, statements) do
    solve(predicates, statements, %{})
  end

  def solve([], _statements, prev_result) do
    [prev_result]
  end
  def solve([first_predicate | tail_predicates], statements, prev_result)
    when is_function(first_predicate) do
    if first_predicate.(prev_result) do
      solve(tail_predicates, statements, prev_result)
    else
      []
    end
  end
  def solve([first_predicate | tail_predicates], statements, prev_result) do
    first_predicate
    |> apply_substitution(prev_result)
    |> unify(statements)
    |> Enum.map(&Map.merge(prev_result, &1))
    |> Enum.map(&Task.async(
        Triplex.Unification, :solve, [tail_predicates, statements, &1]
    ))
    |> Enum.map(&Task.await/1)
    |> List.flatten()
  end

  defp apply_substitution(predicate, results) when is_tuple(predicate) do
    predicate
    |> Tuple.to_list()
    |> Enum.map(&Variable.substitute(&1, results))
    |> List.to_tuple()
  end
  defp apply_substitution(predicate, results) when is_map(predicate) do
    predicate
    |> Map.to_list()
    |> Enum.map(&Variable.substitute(&1, results))
    |> Map.new()
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

  def unify(predicate, statement) do
    unify(predicate, statement, %{})
  end

  def unify(%Variable{name: name}, value, solutions) do
    Map.put solutions, name, value
  end
  def unify(predicate, statement, solutions)
    when
      is_tuple(predicate) and
      is_tuple(statement) and
      tuple_size(predicate) == tuple_size(statement)
    do
    [predicate, statement]
    |> List.zip()
    |> Enum.reduce_while(
      solutions,
      fn ({predicate, statement}, solutions) ->
        solutions = unify(predicate, statement, solutions)
        if solutions == nil, do: {:halt, nil}, else: {:cont, solutions}
      end
    )
  end

  def unify(predicate, statement, solutions)
    when
      is_map(predicate) and is_map(statement)
    do
    predicate
    |> Map.to_list()
    |> Enum.reduce_while(
      solutions,
      fn ({key, u_val}, solutions) ->
        if Map.has_key?(statement, key) do
          solutions = unify(u_val, Map.get(statement, key), solutions)
          if solutions == nil, do: {:halt, nil}, else: {:cont, solutions}
        else
          {:halt, nil}
        end
      end
    )
    |> (fn (solutions) -> if(solutions == %{}, do: nil, else: solutions) end).()
  end

  def unify(x, y, solutions) do
    if x == y, do: solutions, else: nil
  end

end
