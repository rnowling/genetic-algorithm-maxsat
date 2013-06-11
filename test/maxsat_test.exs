Code.require_file "test_helper.exs", __DIR__

defmodule MaxSATTest do
  use ExUnit.Case


  test "read problem" do
    problem = MaxSAT.Functions.read_problem("data/problems/uf250-01.cnf")
    assert problem.num_variables == 250
    assert problem.num_clauses == 1065
    assert length(problem.clauses) == problem.num_clauses
    assert Enum.all?(problem.clauses, fn c -> length(c) == 3 end)
  end

  test "mutate" do
    solution = :array.from_list([1, 0, 1, 1, 1])
    mutant = MaxSAT.Functions.mutate(solution)
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
    child = MaxSAT.Functions.crossover(solution1, solution2)
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
    assert MaxSAT.Functions.merge(0, 2, parent1, parent2) == :array.get(0, parent1)
    assert MaxSAT.Functions.merge(1, 2, parent1, parent2) == :array.get(1, parent1)
    assert MaxSAT.Functions.merge(2, 2, parent1, parent2) == :array.get(2, parent1)
    assert MaxSAT.Functions.merge(3, 2, parent1, parent2) == :array.get(3, parent2)
    assert MaxSAT.Functions.merge(4, 2, parent1, parent2) == :array.get(4, parent2)
  end

  test "random init" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    random_solution = MaxSAT.Functions.random_init(problem.num_variables)
    assert :array.size(random_solution) == problem.num_variables
    assert Enum.all?(:array.to_list(random_solution), fn v -> v == 0 or v == 1 end)
  end

  test "fitness" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution = :array.from_list([1, 0, 1, 1, 1])
    assert MaxSAT.Functions.get_variable(1, solution) == 1
    assert MaxSAT.Functions.get_variable(2, solution) == 0
    assert MaxSAT.Functions.get_variable(-1, solution) == 0
    assert MaxSAT.Functions.get_variable(-2, solution) == 1
    sat_clause = [1, -2, 3]
    unsat_clause = [4, -5, 1]
    assert MaxSAT.Functions.check_satisfied(sat_clause, solution)
    refute MaxSAT.Functions.check_satisfied(unsat_clause, solution)
    assert MaxSAT.Functions.fitness(problem, solution) == 2
  end
end











