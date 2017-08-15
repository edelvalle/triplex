defmodule Triplex.Variable.Operator do

  def _a + _b do
    1
  end

end

defmodule Triplex.Variable do
  @enforce_keys [:name]
  defstruct name: nil, operator: '=', other: nil
  # @operators = %{
  #   "==": :qe,
  #   "in": :in,
  #   ">": :lt,
  #   "=>": :lte,

  #   "!=": :not_eq,
  #   "not in": :not_in,
  #   "<": :gt,
  #   "<=": :gte,
  # }

  defmacro where(what_ever) do
    quote do
      import Kernel, except: [+: 2]
      import Triplex.Variable.Operator
      unquote(what_ever)
    end
  end

  def is?(value) do
    match?(%Triplex.Variable{}, value)
  end
end
