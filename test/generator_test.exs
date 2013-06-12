Code.require_file "test_helper.exs", __DIR__

defmodule GeneratorTest do
  use ExUnit.Case
  alias GeneticAlgorithms.MaxSATIndividual, as: Individual
  alias GeneticAlgorithms.Generator, as: Generator
  alias MaxSAT.Functions, as: Functions

  test "choose four" do
    pids = :array.from_list([0, 1, 2, 3])
    chosen = tuple_to_list(Generator.choose_four(pids))
    in_range = fn x -> x >= 0 and x <= 3 end
    assert Enum.all?(chosen, in_range)
  end

  test "get fitness" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution = :array.from_list([1, 0, 1, 1, 1])
    pid = spawn(Individual, :start, [problem, solution])
    fitness = Generator.get_fitness(pid, 0)
    assert fitness == Functions.fitness(problem, solution)
  end

  test "binary tournament" do
    individual1 = {1, 0}
    individual2 = {2, 1}
    resulting_pid = Generator.binary_tournament(individual1, individual2)
    assert resulting_pid == 1
  end

  test "get solution" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution = :array.from_list([1, 0, 1, 1, 1])
    pid = spawn(Individual, :start, [problem, solution])
    recv_solution = Generator.get_solution(pid, 0)
    assert solution == recv_solution
  end

  test "send updated solution" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution1 = :array.from_list([1, 0, 1, 1, 1])
    solution2 = :array.from_list([1, 2, 1, 1, 1])
    pid = spawn(Individual, :start, [problem, solution1])
    next_gen = Generator.send_updated_solution(pid, solution2, 0)   
    assert next_gen == 1
    recv_solution = Generator.get_solution(pid, next_gen)
    assert recv_solution == solution2
  end

 end