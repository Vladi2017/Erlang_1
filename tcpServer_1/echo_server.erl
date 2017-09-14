-module(echo_server).
-export([start/1, loop/2]).
-record(vars, {bin1, iter1}).

% echo_server: delay = keepalive_interval
% http://erlang.org/doc/programming_examples/bit_syntax.html
start(Port) ->
	io:format("echo_server rel.8~n"),
	{ok,Pid} = socket_server:start(?MODULE, Port, {?MODULE, loop}),
	error_logger:info_msg("Started TCP server. ~w~n", [Pid]).
loop(Socket,start) ->
	ok = gen_tcp:send(Socket, <<"keepalive",0,0,0,1,"delay",2>>),
	error_logger:info_msg("TCP client connected. ~n"),
	loop(Socket,run);
loop(Socket,_) ->
    case gen_tcp:recv(Socket, 0, 7000) of % recv(Socket, Length, Timeout) -> {ok, Packet} | {error, Reason}
		{ok, <<"server_down_cmd\n">>} ->
			server_down;
		{ok, <<"session_down_cmd\n">>} ->
			session_down;
		{ok, <<"response",Seq:4/signed-integer-unit:8,"delay",Delay:1/signed-integer-unit:8>>} ->
			timer:sleep(Delay*10*1000),
			Result1 = gen_tcp:send(Socket,<<"keepalive",(Seq+1):4/signed-integer-unit:8,"delay",Delay:1/signed-integer-unit:8>>),
			case Result1 of
				ok -> ok;
				_Else -> error_logger:info_msg("Vl1. gen_tcp:send(..) returned: ~w~n", [Result1])
			end,
            loop(Socket,run);
        {ok, Data} ->
			timer:sleep(3000),
            gen_tcp:send(Socket, Data),
            loop(Socket,run);
        {error, closed} ->
			error_logger:info_msg("Vl2. received {error, closed}~n"),
            ok;
		Other ->
			error_logger:info_msg("Vl3. received ~w~n", [Other])
    end.
