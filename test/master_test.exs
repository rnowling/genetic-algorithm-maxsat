Code.require_file "test_helper.exs", __DIR__

defmodule MasterTest do
  use ExUnit.Case
  alias GeneticAlgorithms.Master, as: Master

  test "solve problem 10 generations" do
    problem = MaxSAT.Functions.read_problem("data/problems/uf250-01.cnf")
    n_indiv = 10
    n_gen = 100
    Master.start(problem, n_indiv, n_gen)
  end
end