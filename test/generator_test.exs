Code.require_file "test_helper.exs", __DIR__

defmodule GeneratorTest do
  use ExUnit.Case
  alias GeneticAlgorithms.MaxSATIndividual, as: Individual
  alias GeneticAlgorithms.Generator, as: Generator

  test "mutate" do
    solution = :array.from_list([1, 0, 1, 1, 1])
    mutant = Generator.mutate(solution)
    assert :array.size(solution) == :array.size(mutant)
    solution1 = :array.to_list(solution)
    solution2 = :array.to_list(mutant)
    diff = fn {x1, x2} -> x1 != x2 end
    num_diffs = Enum.count(Enum.zip(solution1, solution2), diff)
    assert num_diffs == 1
  end

  test "crossover" do
    solution1 = :array.from_list([1, 0, 1, 1, 1])
    solution2 = :array.from_list([0, 1, 0, 0, 0])
    child = Generator.crossover(solution1, solution2)
    assert :array.size(child) == :array.size(solution1)
    same_one_parent = fn {c, {p1, p2}} -> p1 == c or p2 == c end
    parent1 = :array.to_list(solution1)
    parent2 = :array.to_list(solution2)
    child_lst = :array.to_list(child)
    combined = Enum.zip(child_lst, Enum.zip(parent1, parent2))
    num_same = Enum.count(combined, same_one_parent)
    assert num_same == :array.size(child)
  end

  test "merge" do
    parent1 = :array.from_list([1, 0, 1, 1, 1])
    parent2 = :array.from_list([0, 1, 0, 0, 0])
    assert Generator.merge(0, 2, parent1, parent2) == :array.get(0, parent1)
    assert Generator.merge(1, 2, parent1, parent2) == :array.get(1, parent1)
    assert Generator.merge(2, 2, parent1, parent2) == :array.get(2, parent1)
    assert Generator.merge(3, 2, parent1, parent2) == :array.get(3, parent2)
    assert Generator.merge(4, 2, parent1, parent2) == :array.get(4, parent2)
  end

 end