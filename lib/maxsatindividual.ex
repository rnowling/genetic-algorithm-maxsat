defmodule GeneticAlgorithms.MaxSATIndividual do
  import GeneticAlgorithms.Utils, only: [fill: 2, random_bit: 0, flip: 1, random_idx: 1]

  def start(problem_instance) do
    me = random_init(problem_instance.num_variables)
    solutions = :array.set(0, me, :array.new)
    server(problem_instance, solutions, 0)
  end

  def start(problem_instance, me) do
    solutions = :array.set(0, me, :array.new)
    server(problem_instance, solutions, 0)
  end

  def random_init(len) do
    fill(len, function(random_bit/0))
  end

  def server(problem_instance, solutions, max_generation) do
    receive do
      # wait until generation is bumped
      {sender, :get_fitness, generation} when generation <= max_generation ->
        me = :array.get(generation, solutions)
        sender <- {self, :fitness_response, generation, fitness(problem_instance, me)}
      # wait until generation is bumped
      {sender, :get_solution, generation} when generation <= max_generation ->
        me = :array.get(generation, solutions)
        sender <- {self, :solution_response, generation, me}
      # only let us receive 1 solution per generation -- make us immutable :)
      {:update_solution, generation, solution} when generation > max_generation ->
        solutions = :array.set(solution, generation, solutions)
        max_generation = generation
      other ->
        IO.puts (inspect self) <> "Received invalid message " <> inspect(other)
    end
    server(problem_instance, solutions, generation)
  end

  def fitness(problem_instance, variables) do
    clause_sat = Enum.map(problem_instance.clauses, check_satisfied(&1, variables))
    num_satisfied_clauses = Enum.count(clause_sat, fn v -> v end)
    num_satisfied_clauses
  end

  def get_variable(variable_idx, variables) do
    idx = abs(variable_idx) - 1
    value = :array.get(idx, variables)
    cond do
      variable_idx > 0 ->
        value
      variable_idx < 0 ->
        flip(value)
    end
  end

  def check_satisfied(clause, variables) do
    clause_variables = Enum.map(clause, get_variable(&1, variables))
    Enum.all?(clause_variables, &1 == 1)
  end
end