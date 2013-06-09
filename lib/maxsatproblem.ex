defrecord MaxSATProblem, num_variables: 0, num_clauses: 0, clauses: nil

defmodule MaxSATFunctions do
  def read_problem(flname) do
    {:ok, problem_text} = File.read(flname)
    lines = String.split(problem_text, "\n")
    parse_lines(lines, [], MaxSATProblem.new)
  end

  defp parse_lines([head | tail], clause_list, problem) do
    line_type = String.at(head, 0)
    cond do
      # comment line -- ignore
      line_type == "c" -> 
        parse_lines(tail, clause_list, problem)
      # problem def line
      line_type == "p" ->
        [_, _, num_variables, num_clauses] = String.split(head)
        problem = problem.num_variables(binary_to_integer(num_variables))
        problem = problem.num_clauses(binary_to_integer(num_clauses))
        parse_lines(tail, clause_list, problem)
      # end of problem
      line_type == "%" ->
        problem.clauses(clause_list)
      # clause
      true ->
        clauses = Enum.map(String.split(head), function(binary_to_integer/1))
          # file format contains a 0 at the end of each clause
          # clauses are 1-index so we can just remove all 0 variables
          clauses = Enum.filter(clauses, fn v -> v !=0 end)
          clause_list = [clauses | clause_list]
          parse_lines(tail, clause_list, problem)
    end
  end
end