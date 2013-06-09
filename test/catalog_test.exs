Code.require_file "test_helper.exs", __DIR__

defmodule CatalogTest do
  use ExUnit.Case
  alias GeneticAlgorithms.Catalog, as: Catalog
  alias GeneticAlgorithms.CatalogState, as: CatalogState
  alias GeneticAlgorithms.Utils, as: Utils

  test "update state - under limit" do
    num_individuals = 50
    current_gen = Utils.fill(100, fn -> :random.uniform(100) - 1 end)
    next_gen = Utils.fill(100, fn -> :random.uniform(100) - 1 end)
    next_gen_expected = :array.set(num_individuals, num_individuals, next_gen)
    state = CatalogState.new(gen_number: 0, tos: current_gen, tng: next_gen, num_received_individuals: num_individuals)
    next_state = Catalog.update_state(state, num_individuals)
    IO.puts inspect next_state
    assert state.gen_number == next_state.gen_number
    assert state.tos == next_state.tos
    assert next_state.num_received_individuals == (num_individuals + 1)
    assert next_state.tng == next_gen_expected
  end

  test "add individual - at limit" do

  end
 end