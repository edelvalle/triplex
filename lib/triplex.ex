defmodule Triplex do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add(server, triplet) when is_tuple(triplet) do
    add(server, [triplet])
  end
  def add(server, triplets) when is_list(triplets) do
    GenServer.cast(server, {:add, triplets})
  end

  def solve(server, predicate) do
    GenServer.call(server, {:solve, predicate})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast({:add, new_triplets}, triplets) do
    {:noreply, new_triplets ++ triplets}
  end

  def handle_call({:solve, predicate}, _from, triplets) do
    {:reply, [predicate], triplets}
  end
end
