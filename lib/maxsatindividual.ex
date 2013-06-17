defmodule GeneticAlgorithms.MaxSATIndividual do
  import MaxSAT.Functions, only: [random_init: 1, fitness: 2]

  def start(problem_instance) do
    #IO.puts "Individual " <> inspect(self)
    :random.seed(:erlang.now())
    me = random_init(problem_instance.num_variables)
    solutions = :array.set(0, me, :array.new)
    server(problem_instance, solutions)
  end

  def start(problem_instance, me) do
    solutions = :array.set(0, me, :array.new)
    server(problem_instance, solutions)
  end

  def server(problem_instance, solutions) do
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

      # only let us receive 1 solution per generation -- enable provinence :)
      {:update_solution, generation, solution} when generation == (max_generation + 1) ->
        max_generation = max_generation + 1
        solutions = :array.set(max_generation, solution, solutions)
    end
    server(problem_instance, solutions, max_generation)
  end

  def dump_messages(generation) do
    receive do
      msg ->
        IO.puts "#{inspect self} unable to process message #{inspect msg}. Generation #{inspect generation}."
    end
    dump_messages(generation)
  end
end