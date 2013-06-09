Code.require_file "test_helper.exs", __DIR__

defmodule MaxSATProblemTest do
  use ExUnit.Case

  test "read problem" do
    problem = MaxSATFunctions.read_problem("data/problems/uf250-01.cnf")
    assert problem.num_variables == 250
    assert problem.num_clauses == 1065
    assert length(problem.clauses) == problem.num_clauses
    assert Enum.all?(problem.clauses, fn c -> length(c) == 3 end)
  end
end











