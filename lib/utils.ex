defmodule GeneticAlgorithms.Utils do
	def sum(coll) do
		List.foldl(coll, 0, &1 + &2)
	end

	defp recur_apply(input, func, 1) do
		func.(input)
	end

	defp recur_apply(input, func, times) do
		output = func.(input)
		recur_apply(output, func, times - 1)
	end

	defp foldr(array, function) do
		last_idx = :array.size(array) - 1
		elem = :array.get(last_idx, array)
		_foldr(array, function, elem, last_idx - 1)
	end

	defp _foldr(array, function, result, 0) do
		elem = :array.get(0, array)
		function.(elem, result)
	end

	defp _foldr(array, function, result, idx) do
		elem = :array.get(idx, array)
		result = function.(elem, result)
		_foldr(array, function, result, idx - 1)
	end

	def fill(size, function) do
		array = :array.new(size)
		_fill(array, function, size - 1)
	end

	defp _fill(array, function, 0) do 
		value = function.()
		:array.set(0, value, array)
	end

	defp _fill(array, function, idx) do
		value = function.()
		array = :array.set(idx, value, array)
		_fill(array, function, idx - 1)
	end

	defp map(in_array, function) do
		size = :array.size(in_array)
		out_array = :array.new(size)
		_map(in_array, function, out_array, size - 1)
	end

	defp _map(in_array, function, out_array, 0) do
		in_value = :array.get(0, in_array)
		out_value = function.(in_value)
		:array.set(0, out_value, out_array)
	end

	defp _map(in_array, function, out_array, idx) do
		in_value = :array.get(0, in_array)
		out_value = function.(in_value)
		out_array.set(0, out_value, out_array)
		_map(in_array, function, out_array, idx - 1)
	end

	def random_bit() do
		:random.uniform(2) - 1
	end

	def random_idx(array) do
		:random.uniform(:array.size(array)) - 1
	end		

	def random_elem(array) do
		idx = random_idx(array)
		:array.get(idx, array)
	end

	def flip(value) do
		rem(value + 1, 2)
	end
end