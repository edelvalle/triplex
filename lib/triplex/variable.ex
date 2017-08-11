defmodule Triplex.Variable do
  defstruct [:name]

  def new(name) do
    %Triplex.Variable{name: name}
  end

  def is?(value) do
    match?(%Triplex.Variable{}, value)
  end
end
