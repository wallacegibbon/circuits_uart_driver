-module(enumeration_demo).

-export([start/0]).

start() ->
  Cmd = filename:join("build", "circuits_uart"),
  Args = [{args, [<<"enumerate">>]}, {packet, 2}, use_stdio, binary, exit_status],
  Port = erlang:open_port({spawn_executable, Cmd}, Args),
  receive
    {Port, {data, <<$r, Message/binary>>}} ->
      erlang:binary_to_term(Message)
  after 5000 ->
    done
  end.
