defmodule GeneticAlgorithms.Generator do
  import MaxSAT.Functions, only: [mate_and_mutate: 2]
  alias GeneticAlgorithms.Utils, as: Utils

  def start(target_pid, individual_pids) do
    :random.seed(:erlang.now())
    Process.put(:target_pid, target_pid)
    Process.put(:individual_pids, individual_pids)
    server()
  end

  def server() do
    server(0)
  end

  def server(generation) do
    check_shutdown()

    # randomly choose 4 individuals
    {indiv1_pid, indiv2_pid, indiv3_pid, indiv4_pid} = choose_four(Process.get(:individual_pids))

    # get their fitness values
    {indiv1_fitness, indiv2_fitness, indiv3_fitness, indiv4_fitness} = get_fitness({indiv1_pid, indiv2_pid, indiv3_pid, indiv4_pid}, generation)

    # perform the binary tournament
    parent1_pid = binary_tournament({indiv1_fitness, indiv1_pid}, {indiv2_fitness, indiv2_pid})
    parent2_pid = binary_tournament({indiv3_fitness, indiv3_pid}, {indiv4_fitness, indiv4_pid})

    # get the solutions of the two winners
    {parent1_solution, parent2_solution} = get_solutions({parent1_pid, parent2_pid}, generation)

    # produce a child
    child_solution = mate_and_mutate(parent1_solution, parent2_solution)

    # send updated solution
    next_generation = generation + 1
    send_updated_solution(Process.get(:target_pid), child_solution, next_generation)
    
    server(next_generation)
  end

  def check_shutdown() do
    receive do
      {:shutdown} ->
        exit(0)
      after 0 ->
        :ok
    end
  end

  def choose_four(individual_pids) do
    indiv1_pid = Utils.random_elem(individual_pids)
    indiv2_pid = Utils.random_elem(individual_pids)
    indiv3_pid = Utils.random_elem(individual_pids)
    indiv4_pid = Utils.random_elem(individual_pids)
    {indiv1_pid, indiv2_pid, indiv3_pid, indiv4_pid}
  end

  def get_fitness({indiv1_pid, indiv2_pid, indiv3_pid, indiv4_pid}, generation) do
    indiv1_pid <- {self, :get_fitness, generation}
    indiv2_pid <- {self, :get_fitness, generation}
    indiv3_pid <- {self, :get_fitness, generation}
    indiv4_pid <- {self, :get_fitness, generation}
    receive do
      {^indiv1_pid, :fitness_response, ^generation, fitness} ->
        indiv1_fitness = fitness
    end
    receive do
      {^indiv2_pid, :fitness_response, ^generation, fitness} ->
        indiv2_fitness = fitness
    end
    receive do
      {^indiv3_pid, :fitness_response, ^generation, fitness} ->
        indiv3_fitness = fitness
    end
    receive do
      {^indiv4_pid, :fitness_response, ^generation, fitness} ->
        indiv4_fitness = fitness
    end
    {indiv1_fitness, indiv2_fitness, indiv3_fitness, indiv4_fitness}
  end

  def binary_tournament({indiv1_fitness, indiv1_pid}, {indiv2_fitness, indiv2_pid}) do
    if indiv1_fitness > indiv2_fitness do
      indiv1_pid
    else
      indiv2_pid
    end
  end

  def get_solutions({indiv1_pid, indiv2_pid}, generation) do
    indiv1_pid <- {self, :get_solution, generation}
    indiv2_pid <- {self, :get_solution, generation}
    receive do
      {^indiv1_pid, :solution_response, ^generation, solution} ->
        solution1 = solution
    end
    receive do
      {^indiv2_pid, :solution_response, ^generation, solution} ->
        solution2 = solution
    end
    {solution1, solution2}
  end

  def send_updated_solution(target_pid, solution, generation) do
    target_pid <- {:update_solution, generation, solution}
  end

 
end