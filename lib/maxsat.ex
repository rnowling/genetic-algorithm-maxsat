defrecord MaxSAT.Problem, num_variables: 0, num_clauses: 0, clauses: nil

defmodule MaxSAT.Functions do
  import GeneticAlgorithms.Utils, only: [random_idx: 1, flip: 1, fill: 2, map: 2, random_bit: 0]

  def read_problem(flname) do
    {:ok, problem_text} = File.read(flname)
    lines = String.split(problem_text, "\n")
    parse_lines(lines, [], MaxSAT.Problem.new)
  end

  defp parse_lines([head | tail], clause_list, problem) do
    line_type = String.at(head, 0)
    cond do
      # comment line -- ignore
      line_type == "c" -> 
        parse_lines(tail, clause_list, problem)
      # problem def line
      line_type == "p" ->
        [_, _, num_variables, num_clauses] = String.split(head)
        problem = problem.num_variables(binary_to_integer(num_variables))
        problem = problem.num_clauses(binary_to_integer(num_clauses))
        parse_lines(tail, clause_list, problem)
      # end of problem
      line_type == "%" ->
        problem.clauses(clause_list)
      # clause
      true ->
        clauses = Enum.map(String.split(head), function(binary_to_integer/1))
          # file format contains a 0 at the end of each clause
          # clauses are 1-index so we can just remove all 0 variables
          clauses = Enum.filter(clauses, fn v -> v !=0 end)
          clause_list = [clauses | clause_list]
          parse_lines(tail, clause_list, problem)
    end
  end

  def mate_and_mutate(parent1_solution, parent2_solution) do
    child = crossover(parent1_solution, parent2_solution)
    mutant = mutate(child)
    mutant
  end

  def crossover(parent1_solution, parent2_solution) do
    crossover_idx = random_idx(parent1_solution)
    merge_fun = fn idx -> merge(idx, crossover_idx, parent1_solution, parent2_solution) end
    end_idx = :array.size(parent1_solution) - 1
    child = :array.from_list(Enum.map(0..end_idx, merge_fun))
    child
  end

  def mutate(individual) do
    mutant_idx = random_idx(individual)
    bit = :array.get(mutant_idx, individual)
    mutant = :array.set(mutant_idx, flip(bit), individual)
    mutant
  end

  def merge(idx, merge_idx, parent1, parent2) do
    if idx <= merge_idx do
      :array.get(idx, parent1)
    else
      :array.get(idx, parent2)
    end
  end

  def random_init(len) do
    fill(len, function(random_bit/0))
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