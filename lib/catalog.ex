defrecord GeneticAlgorithms.CatalogState, gen_number: 0, tos: nil, tng: nil, num_received_individuals: 0

defmodule GeneticAlgorithms.Catalog do
  def start(master_pid, initial_individual_pids) do
    tng = :array.new(:array.size(initial_individual_pids))
    state = CatalogState.new gen_number: 0, tos: initial_individual_pids, tng: tng, num_received_individuals: 0
    server(master_pid, state)
  end

  def server(master_pid, state) do
    gen_number = state.gen_number
    receive do 
      {sender, :choose_four_individuals_randomly, ^gen_number} ->
        sender <- four_random_individuals(state.tos)
      {:add_individual, indiv_pid} ->
        state = update_state(state, indiv_pid)
        master_pid <- {:finished_generation, state.gen_number, state.tng}
      Other ->
        IO.puts "Got invalid message " <> inspect(Other)
    end
    server(master_pid, state)
  end

  def update_state(state, individual_pid) do
    state = state.tng(:array.set(state.num_received_individuals, individual_pid, state.tng))
    state = state.num_received_individuals(state.num_received_individuals + 1)
    if state.num_received_individuals == :array.size(state.tos) do
      state = state.gen_number(state.gen_number + 1)
      state = state.tos(state.tng)
    end
    state
  end

  def four_random_individuals(individuals) do
    indiv1 = Utils.random_elem(individuals)
    indiv2 = Utils.random_elem(individuals)
    indiv3 = Utils.random_elem(individuals)
    indiv4 = Utils.random_elem(individuals)
    {indiv1, indiv2, indiv3, indiv4}
  end
end