defmodule GeneticAlgorithms.MaxSATIndividual do
  import MaxSAT.Functions, only: [random_init: 1, fitness: 2]

  def start(problem_instance) do
    me = random_init(problem_instance.num_variables)
    solutions = :array.set(0, me, :array.new)
    server(problem_instance, solutions, 0)
  end

  def start(problem_instance, me) do
    solutions = :array.set(0, me, :array.new)
    server(problem_instance, solutions, 0)
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
        solutions = :array.set(generation, solution, solutions)
        max_generation = generation

      # catch bad messages
      #other ->
      #  IO.puts (inspect self) <> "Received invalid message " <> inspect(other)
    end
    server(problem_instance, solutions, generation)
  end
end