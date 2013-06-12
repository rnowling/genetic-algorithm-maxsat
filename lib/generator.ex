defmodule GeneticAlgorithms.Generator do
  import MaxSAT.Functions, only: [mate_and_mutate: 2]
  import GeneticAlgorithms.Utils, as: Utils

  def start(target_pid, individual_pids) do
    start(target_pid, individual_pids, 0)
  end

  def start(target_pid, individual_pids, generation) do
    # randomly choose 4 individuals
    {indiv1_pid, indiv2_pid, indiv3_pid, indiv4_pid} = choose_four(individual_pids)

    # get their fitness values
    indiv1_fitness = get_fitness(indiv1_pid, generation)
    indiv2_fitness = get_fitness(indiv2_pid, generation)
    indiv3_fitness = get_fitness(indiv3_pid, generation)
    indiv4_fitness = get_fitness(indiv4_pid, generation)

    # perform the binary tournament
    parent1_pid = binary_tournament({indiv1_fitness, indiv1_pid}, {indiv2_fitness, indiv2_pid})
    parent2_pid = binary_tournament({indiv3_fitness, indiv3_pid}, {indiv4_fitness, indiv4_pid})

    # get the solutions of the two winners
    parent1_solution = get_solution(parent1_pid, generation)
    parent2_solution = get_solution(parent2_pid, generation)

    # produce a child
    child_solution = mate_and_mutate(parent1_solution, parent2_solution)

    # send updated solution
    next_generation = send_updated_solution(target_pid, child_solution, generation)
    
    start(target_pid, individual_pids, next_generation)
  end

  def choose_four(individual_pids) do
    indiv1_pid = Utils.random_elem(individual_pids)
    indiv2_pid = Utils.random_elem(individual_pids)
    indiv3_pid = Utils.random_elem(individual_pids)
    indiv4_pid = Utils.random_elem(individual_pids)
    {indiv1_pid, indiv2_pid, indiv3_pid, indiv4_pid}
  end

  def get_fitness(indiv_pid, generation) do
    indiv_pid <- {self, :get_fitness, generation}
    receive do
      {^indiv_pid, :fitness_response, ^generation, fitness} ->
        fitness
    end
  end

  def binary_tournament({indiv1_fitness, indiv1_pid}, {indiv2_fitness, indiv2_pid}) do
    if indiv1_fitness > indiv2_fitness do
      indiv1_pid
    else
      indiv2_pid
    end
  end

  def get_solution(indiv_pid, generation) do
    indiv_pid <- {self, :get_solution, generation}
    receive do
      {^indiv_pid, :solution_response, ^generation, solution} ->
        solution
    end
  end

  def send_updated_solution(target_pid, solution, generation) do
    next_generation = generation + 1
    target_pid <- {:update_solution, next_generation, solution}
    next_generation
  end

 
end