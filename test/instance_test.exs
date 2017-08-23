defmodule TriplexTest.InstanceTest do
  use ExUnit.Case, async: false
  alias Triplex.Instance

  setup do
    {:ok, instance} = start_supervised Instance
    %{instance: instance}
  end

  test "test state in instances can time travel", %{instance: instance} do

    Instance.set instance, %{name: "Alex", age: 12}
    before_birthday = Timex.now

    assert Instance.get(instance) == %{name: "Alex", age: 12}
    assert Instance.get(instance, attr: :name) == "Alex"
    assert Instance.get(instance, attr: :age) == 12

    Instance.set instance, :age, 13
    assert Instance.get(instance) == %{name: "Alex", age: 13}
    assert Instance.get(instance, attr: :name) == "Alex"
    assert Instance.get(instance, attr: :age) == 13

    assert Instance.get(instance, at: before_birthday) == %{name: "Alex", age: 12}
    assert Instance.get(instance, attr: :name, at: before_birthday) == "Alex"
    assert Instance.get(instance, attr: :age, at: before_birthday) == 12
  end
end
