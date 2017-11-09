-module(echo_server).
-export([start/1, loop/2]).
-record(vars, {bin1, iter1}).
-define(timeout, 600000).

% echo_server: delay = keepalive_interval
% http://erlang.org/doc/programming_examples/bit_syntax.html
start(Port) ->
	io:format("echo_server rel.12, using gen_tcp:recv/3 & non-blocking graph~n"),
	{ok,Pid} = socket_server:start(?MODULE, Port, {?MODULE, loop}),
	error_logger:info_msg("Started TCP server. ~w~n", [Pid]).
loop(Socket,start) ->
	{ok,TRef1} = timer:apply_after(2000,?MODULE,delayedKA,[Socket,0,2]),
	error_logger:info_msg("TCP client connected. Traffic socket: ~w~n", [Socket]),
	loop(Socket,TRef1);
loop(Socket,TRef) ->
    case gen_tcp:recv(Socket, 0, ?timeout) of % recv(Socket, Length, Timeout) -> {ok, Packet} | {error, Reason}
		{ok, <<"server_down_cmd\n">>} ->
			{ok, cancel} = timer:cancel(TRef),
			server_down;
		{ok, <<"session_down_cmd\n">>} ->
			{ok, cancel} = timer:cancel(TRef),
			session_down;
		{ok, <<"response",Seq:4/signed-integer-unit:8,"delay",Delay:1/signed-integer-unit:8>>} ->
			io:format("~w", [Seq]),
			{ok,TRef1} = timer:apply_after(Delay*10*1000,?MODULE,delayedKA,[Socket,Seq,Delay]),
            loop(Socket,TRef1);
        {ok, Data} ->
			timer:sleep(3000),
            gen_tcp:send(Socket, Data),
            loop(Socket,TRef);
        % {error, closed} ->
			% error_logger:info_msg("Vl2. received {error, closed}~n"),
            % ok;
		Other ->
			% error_logger:info_msg("Vl3. received ~w~n", [Other])
			{ok, cancel} = timer:cancel(TRef),
			Other
    end.
delayedKA([Socket,Seq,Delay]) ->
	Result1 = gen_tcp:send(Socket,<<"keepalive",(Seq+1):4/signed-integer-unit:8,"delay",Delay:1/signed-integer-unit:8>>),
	case Result1 of
		ok -> ok;
		_Else -> error_logger:info_msg("Vl1. gen_tcp:send(..) returned: ~w~n", [Result1])
	end,
	io:format(",").
