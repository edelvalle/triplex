
defmodule Triplex.Variable do
  defstruct [:name]

  def v(name) do
    %Triplex.Variable{name: name}
  end

  def is?(value) do
    match?(%Triplex.Variable{}, value)
  end

  def substitute(%Triplex.Variable{}=variable, context) do
    Map.get(context, variable.name, variable)
  end
  def substitute(item, _context) do
    item
  end
end
