defmodule GeneticAlgorithms.Crossover do
	import GeneticAlgorithms.Utils, only: [random_idx: 1, map: 2, flip: 1]

	def start(target_pid) do
		wait_for_pid(target_pid)
	end

	def wait_for_pid(target_pid) do
		receive do
			{:parent_pid, parent_pid} ->
				parent_pid <- {self, :get_solution}
				wait_for_pid_or_solution(target_pid, parent_pid)
		end
	end

	def wait_for_pid_or_solution(target_pid, parent1_pid) do
		receive do
			{:parent_pid, parent2_pid} ->
				parent2_pid <- {self, :get_solution}
				wait_for_solution(target_pid, parent1_pid, parent2_pid)
			{^parent1_pid, :solution_response, parent1_solution} ->
				wait_for_second_pid(target_pid, parent1_solution)
		end
	end

	def wait_for_solution(target_pid, parent1_pid, parent2_pid) do
		receive do
			{^parent1_pid, :solution_response, parent1_solution} ->
				wait_for_second_solution(target_pid, parent2_pid, parent1_solution)
			{^parent2_pid, :solution_response, parent2_solution} ->
				wait_for_second_solution(target_pid, parent1_pid, parent2_solution)
		end
	end

	def wait_for_second_pid(target_pid, parent1_solution) do
		receive do
			{:parent_pid, parent2_pid} ->
				wait_for_second_solution(target_pid, parent2_pid, parent1_solution)
		end
	end

	def wait_for_second_solution(target_pid, parent_pid, parent1_solution) do
		receive do
			{^parent_pid, :solution_response, parent2_solution} ->
				child = mate_and_mutate(parent1_solution, parent2_solution)
				target_pid <- {:update_solution, child}
		end
		wait_for_pid(target_pid)
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