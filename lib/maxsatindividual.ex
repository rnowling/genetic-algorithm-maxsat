defmodule GeneticAlgorithms.MaxSATIndividual do
  import GeneticAlgorithms.Utils, only: [fill: 2, random_bit: 0, flip: 1, random_idx: 1]

  def start(problem_instance) do
    me = random_init(problem_instance.num_variables)
    server(problem_instance, me)
  end

  def start(problem_instance, me) do
    server(problem_instance, me)
  end

  def random_init(len) do
    fill(len, function(random_bit/0))
  end

  def server(problem_instance, me) do
    receive do
      {sender, :get_fitness} ->
        sender <- {self, :fitness_response, fitness(problem_instance, me) }
        server(problem_instance, me)
      {sender, :get_solution} ->
        sender <- {self, :solution_response, me}
        server(problem_instance, me)
      {:update_solution, solution} ->
        me = solution
      other ->
        IO.puts (inspect self) <> "Received invalid message " <> inspect(other)
    end
    server(problem_instance, me)
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