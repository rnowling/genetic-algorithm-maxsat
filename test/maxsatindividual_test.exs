Code.require_file "test_helper.exs", __DIR__

defmodule MaxSATIndividualTest do
  use ExUnit.Case
  alias GeneticAlgorithms.MaxSATIndividual, as: Individual

  test "read problem" do
  	problem = MaxSATFunctions.read_problem("data/problems/uf250-01.cnf")
  	assert problem.num_variables == 250
  	assert problem.num_clauses == 1065
  	assert length(problem.clauses) == problem.num_clauses
  	assert Enum.all?(problem.clauses, fn c -> length(c) == 3 end)
  end

  test "random init" do
  	problem = MaxSATProblem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
  	random_solution = Individual.random_init(problem.num_variables)
  	assert :array.size(random_solution) == problem.num_variables
  	assert Enum.all?(:array.to_list(random_solution), fn v -> v == 0 or v == 1 end)
  end

  test "individual random init server" do
  	problem = MaxSATProblem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
  	pid = spawn(Individual, :start, [problem])
  	pid <- {self, :get_solution}
  	assert_receive {^pid, :solution_response, solution}, 5_000, "Failed to receive response from MaxSATIndividual"
  	assert :array.size(solution) == problem.num_variables
  	assert Enum.all?(:array.to_list(solution), fn v -> v == 0 or v == 1 end)
  end

  test "fitness" do
  	problem = MaxSATProblem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
  	solution = :array.from_list([1, 0, 1, 1, 1])
  	assert Individual.get_variable(1, solution) == 1
  	assert Individual.get_variable(2, solution) == 0
  	assert Individual.get_variable(-1, solution) == 0
  	assert Individual.get_variable(-2, solution) == 1
  	sat_clause = [1, -2, 3]
  	unsat_clause = [4, -5, 1]
  	assert Individual.check_satisfied(sat_clause, solution)
  	refute Individual.check_satisfied(unsat_clause, solution)
  	assert Individual.fitness(problem, solution) == 2
  	pid = spawn(Individual, :start, [problem, solution])
  	pid <- {self, :get_fitness}
  	assert_receive {^pid, :fitness_response, value}, 1_000, "Failed to receive fitness from MaxSATIndividual"
  	assert value == 2
  end

  test "receiving solution" do
  	problem = MaxSATProblem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
  	solution = :array.from_list([1, 0, 1, 1, 1])
  	pid = spawn(Individual, :start, [problem, solution])
  	pid <- {self, :get_solution}
  	assert_receive {^pid, :solution_response, received_solution}, 1_000, "Failed to receive solution from MaxSATIndividual"
  	assert solution == received_solution
  end

  test "updating solution" do
  	problem = MaxSATProblem.new num_variables: 5, num_clauses: 3, clauses: [[1, -2, 3], [4, -5, 1], [-2, 3, 4]]
  	solution = :array.from_list([1, 0, 1, 1, 1])
  	pid = spawn(Individual, :start, [problem])
  	pid <- {:update_solution, solution}
  	pid <- {self, :get_solution}
  	assert_receive {^pid, :solution_response, received_solution}, 1_000, "Failed to receive solution from MaxSATIndividual"
  	assert solution == received_solution
  end
end











