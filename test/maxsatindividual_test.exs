Code.require_file "test_helper.exs", __DIR__

defmodule MaxSATIndividualTest do
  use ExUnit.Case
  alias GeneticAlgorithms.MaxSATIndividual, as: Individual
  alias MaxSAT.Functions, as: Functions

  test "individual random init server" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    pid = spawn(Individual, :start, [problem])
    pid <- {self, :get_solution, 0}
    assert_receive {^pid, :solution_response, 0, solution}, 1_000, "Failed to receive response from MaxSATIndividual"
    assert :array.size(solution) == problem.num_variables
    assert Enum.all?(:array.to_list(solution), fn v -> v == 0 or v == 1 end)
  end

  test "fitness" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution = :array.from_list([1, 0, 1, 1, 1])
    pid = spawn(Individual, :start, [problem, solution])
    pid <- {self, :get_fitness, 0}
    assert_receive {^pid, :fitness_response, 0, value}, 1_000, "Failed to receive fitness from MaxSATIndividual"
    assert value == 2
  end

  test "receiving solution" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution = :array.from_list([1, 0, 1, 1, 1])
    pid = spawn(Individual, :start, [problem, solution])
    pid <- {self, :get_solution, 0}
    assert_receive {^pid, :solution_response, 0, received_solution}, 1_000, "Failed to receive solution from MaxSATIndividual"
    assert solution == received_solution
  end

  test "updating solution" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution = :array.from_list([1, 0, 1, 1, 1])
    pid = spawn(Individual, :start, [problem])
    pid <- {:update_solution, 1, solution}
    pid <- {self, :get_solution, 1}
    assert_receive {^pid, :solution_response, 1, received_solution}, 1_000, "Failed to receive solution from MaxSATIndividual"
    assert solution == received_solution
  end

  test "block test" do
    problem = MaxSAT.Problem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
    solution0 = :array.from_list([1, 0, 1, 1, 1])
    solution1 = :array.from_list([1, 1, 1, 1, 1])
    solution2 = :array.from_list([1, 1, 1, 1, 0])
    solution3 = :array.from_list([0, 0, 0, 0, 0])

    fitness0 = Functions.fitness(problem, solution0)
    fitness1 = Functions.fitness(problem, solution1)
    fitness2 = Functions.fitness(problem, solution2)
    fitness3 = Functions.fitness(problem, solution3)

    pid = spawn(Individual, :start, [problem, solution0])
    pid <- {self, :get_fitness, 0}
    pid <- {self, :get_fitness, 1}
    pid <- {self, :get_fitness, 2}
    assert_receive {^pid, :fitness_response, 0, ^fitness0}, 10_000, "Failed to receive fitness 0 from Individual"
    pid <- {:update_solution, 1, solution1}
    pid <- {:update_solution, 2, solution2}
    assert_receive {^pid, :fitness_response, 1, ^fitness1}, 10_000, "Failed to receive fitness 1 from Individual"
    assert_receive {^pid, :fitness_response, 2, ^fitness2}, 10_000, "Failed to receive fitness 2 from Individual"
  end
end











