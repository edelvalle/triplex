defmodule Triplex.Instance do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def set(server, %{}=data) do
    GenServer.cast server, {:set, data, Timex.now}
  end

  def set(server, attr, value) do
    GenServer.cast server, {:set, attr, value, Timex.now}
  end

  def get(server, opts \\ []) do
    attr = opts[:attr]
    date = opts[:at] || Timex.now
    if attr == nil do
      GenServer.call server, {:get, date}
    else
      GenServer.call server, {:get, attr, date}
    end
  end

  ## Server Callbacks

  def handle_cast({:set, %{}=data, date}, obj) do
    new_obj = data
      |> Enum.map(fn ({attr, value}) -> {attr, set_attr(obj, attr, value, date)} end)
      |> Map.new()
    {:noreply, new_obj}
  end

  def handle_cast({:set, attr, value, date}, obj) do
    new_obj = Map.put(obj, attr, set_attr(obj, attr, value, date))
    {:noreply, new_obj}
  end

  def handle_call({:get, date}, _from, obj) do
    current_state = obj
    |> Map.keys()
    |> Enum.map(fn (attr) -> {attr, get_attr(obj, attr, date)} end)
    |> Map.new()
    {:reply, current_state, obj}
  end

  def handle_call({:get, attr, date}, _from, obj) do
    {:reply, get_attr(obj, attr, date), obj}
  end

  defp set_attr(obj, attr, value, date) do
    [{date, value} | Map.get(obj, attr, [])]
    |> Enum.sort()
    |> Enum.reverse()
  end

  def get_attr(obj, attr, date) do
    obj
    |> Map.get(attr, [])
    |> Enum.find(fn ({created, _value}) -> created <= date end)
    |> (fn (result) ->
      case result do
        nil -> nil
        {_created, value} -> value
      end
    end).()
  end

end
