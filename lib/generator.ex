defmodule GeneticAlgorithms.Generator do
  import GeneticAlgorithms.Utils, only: [random_idx: 1, map: 2, flip: 1]

  def start(target_pid, individual_pids) do
    start(target_pid, individual_pids, 0)
  end

  def start(target_pid, individual_pids, generation) do
    # randomly choose 4 individuals
    indiv1_pid = Utils.random_elem(individual_pids)
    indiv2_pid = Utils.random_elem(individual_pids)
    indiv3_pid = Utils.random_elem(individual_pids)
    indiv4_pid = Utils.random_elem(individual_pids)

    # get their fitness values
    indiv1_pid <- {self, :get_fitness, generation}
    indiv2_pid <- {self, :get_fitness, generation}
    indiv3_pid <- {self, :get_fitness, generation}
    indiv4_pid <- {self, :get_fitness, generation}
    receive do
      {^indiv1_pid, :fitness_response, ^generation, fitness} ->
        indiv1_fitness = fitness
      {^indiv2_pid, :fitness_response, ^generation, fitness} ->
        indiv2_fitness = fitness
      {^indiv3_pid, :fitness_response, ^generation, fitness} ->
        indiv3_fitness = fitness
      {^indiv4_pid, :fitness_response, ^generation, fitness} ->
        indiv4_fitness = fitness
    end

    # perform the binary tournament
    {_, parent1_pid} = max({indiv1_fitness, indiv1_pid}, {indiv2_fitness, indiv2_pid})
    {_, parent2_pid} = max({indiv3_fitness, indiv3_pid}, {indiv4_fitness, indiv4_pid})

    # get the solutions of the two winners
    parent1_pid <- {self, :get_solution, generation}
    parent2_pid <- {self, :get_solution, generation}
    receive do
      {^parent1_pid, :solution_response, ^generation, solution} ->
        parent1_solution = solution
      {^parent2_pid, :solution_response, ^generation, solution} ->
        parent2_solution = solution
    end
    receive do
      {^parent1_pid, :solution_response, ^generation, solution} ->
        parent1_solution = solution
      {^parent2_pid, :solution_response, ^generation, solution} ->
        parent2_solution = solution
    end

    # produce a child
    child_solution = mate_and_mutate(parent1_solution, parent2_solution)

    next_generation = generation + 1
    target_pid <- {:update_solution, next_generation, child_solution}
    start(target_pid, individual_pids, next_generation)
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
end