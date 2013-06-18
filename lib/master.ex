defmodule GeneticAlgorithms.Master do
  alias GeneticAlgorithms.MaxSATIndividual, as: Individual
  alias GeneticAlgorithms.Generator, as: Generator
  alias MaxSAT.Functions, as: Functions

  def start(problem, num_individuals, num_generations) do
    individual_pids = Enum.map(1..num_individuals, fn _ -> spawn(Individual, :start, [problem]) end)
    individual_pids_array = :array.from_list(individual_pids)
    generator_pids = Enum.map(individual_pids, fn indiv_pid -> spawn(Generator, :start, [indiv_pid, individual_pids_array]) end)
    Process.put(:individual_pids, individual_pids)
    Process.put(:generator_pids, generator_pids)
    server(num_generations)
  end

  def server(num_generations) do
    dummy = {0, nil}
    server(dummy, 0, num_generations)
  end

  def server(best_so_far, current_gen, 0) do
    {best_fitness, _} = best_so_far
    IO.puts "Generation #{inspect current_gen} best fitness #{inspect best_fitness}"
    shutdown(Process.get(:individual_pids), Process.get(:generator_pids))
  end

  def server(best_so_far, current_gen, remaining_gen) do
    fitness_values_pids = get_fitness_values(Process.get(:individual_pids), current_gen)
    best_gen = Enum.max(fitness_values_pids)
    best_so_far = max(best_gen, best_so_far)
    {best_fitness, _} = best_so_far
    IO.puts "Generation #{inspect current_gen} best fitness #{inspect best_fitness}"
    server(best_so_far, current_gen + 1, remaining_gen - 1)
  end

  def shutdown(individual_pids, generator_pids) do
    Enum.map(generator_pids, function(send_shutdown/1))
    Enum.map(individual_pids, function(send_shutdown/1))
  end

  def send_shutdown(pid) do
    pid <- {:shutdown}
  end

  def get_fitness_values(individual_pids, current_gen) do
    send_req = fn pid -> send_fitness_request(pid, current_gen) end
    Enum.map(individual_pids, send_req)
    recv_req = fn pid -> receive_fitness(pid, current_gen) end
    fitness_values = Enum.map(individual_pids, recv_req)
    Enum.zip(fitness_values, individual_pids)
  end

  def send_fitness_request(pid, current_gen) do
    pid <- {self, :get_fitness, current_gen}
  end

  def get_solutions(individual_pids, current_gen) do
    send_req = fn pid -> pid <- {self, :get_solution, current_gen} end
    Enum.map(individual_pids, send_req)
    recv_req = fn pid -> receive_solution(pid, current_gen) end
    solutions = Enum.map(individual_pids, recv_req)
    Enum.zip(solutions, individual_pids)
  end

  def send_solution_request(pid, current_gen) do
    pid <- {self, :get_solution, current_gen}
  end

  def receive_solution(pid, current_gen) do
    receive do
      {^pid, :solution_response, ^current_gen, solution} ->
        solution
    end
  end

  def receive_fitness(pid, current_gen) do
    receive do
      {^pid, :fitness_response, ^current_gen, fitness} ->
        fitness
    end
  end

end