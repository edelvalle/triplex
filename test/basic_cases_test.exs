defmodule TriplexTest.SimplestUnificationTest do
  use ExUnit.Case, async: false
  import Triplex.Unification, only: [unify: 2]
  import Triplex.Variable, only: [v: 1]

  test "simplest case" do
    assert unify(v(:x), 1) == %{x: 1}
  end

  test "can solve simplest tuple case" do
    assert unify({1, v(:x)}, {1, 2}) == %{x: 2}
  end

  test "can solve tuples with multiple vars" do
    assert unify({v(:y), v(:x)}, {1, 2}) == %{y: 1, x: 2}
  end

  test "irregular tuple size causes fail" do
    assert unify({1, v(:x), 2}, {1, 2}) == nil
  end

  test "using a tuples that don't match fails" do
    assert unify({v(:y), v(:x), 1}, {1, 2, 2}) == nil
  end

  test "can solve maps" do
    assert unify(%{g: v(:x), l: 1}, %{g: 12, l: 1}) == %{x: 12}
  end
    test "can empty map as query fails" do
    assert unify(%{}, %{g: 12, l: 1}) == nil
  end

  test "can solve maps with multiple vars" do
    assert unify(%{g: v(:x), l: v(:y)}, %{g: 12, l: 1}) == %{x: 12, y: 1}
  end
end

