-module(read_write_demo).

-export([start/0]).

start() ->
    Cmd = filename:join("build", "circuits_uart"),
    Args = [{args, []}, {packet, 2}, use_stdio, binary, exit_status],
    Port = erlang:open_port({spawn_executable, Cmd}, Args),
    ok = call_port(Port, open, {<<"/dev/ttyUSB2">>, [{speed, 19200}]}),
    Self = self(),
    _ = spawn_link(fun() -> message_generate(Self, 0) end),
    ok = call_port(Port, write, {<<"hello, world!\r\n">>, 2000}),
    loop(Port).

call_port(Port, Command, Arguments) ->
    Port ! {self(), {command, term_to_binary({Command, Arguments})}},
    receive
        {Port, {data, <<$r, Response/binary>>}} ->
            binary_to_term(Response)
    end.

loop(Port) ->
    receive
        {Port, {data, <<$n, Message/binary>>}} ->
            io:format("~p~n", [binary_to_term(Message)]),
            loop(Port);
        {send_data, BinaryData} ->
            ok = call_port(Port, write, {BinaryData, 2000}),
            loop(Port)
    end.

message_generate(Parent, N) ->
    Parent ! {send_data, list_to_binary(io_lib:format("The value of N is ~w\r\n", [N]))},
    timer:sleep(2000),
    message_generate(Parent, N + 1).
