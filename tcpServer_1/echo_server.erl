-module(echo_server).
-export([start/0, loop/2]).

% echo_server specific code
% http://erlang.org/doc/programming_examples/bit_syntax.html
start() ->
	socket_server:start(?MODULE, 7000, {?MODULE, loop}).
loop(Socket,start) ->
	gen_tcp:send(Socket, <<"keepalive",0,0,0,1,"delay",2>>),
	loop(Socket,run);
loop(Socket,_) ->
    case gen_tcp:recv(Socket, 0) of
		{ok, <<"server_down_cmd\n">>} ->
			server_down;
		{ok, <<"session_down_cmd\n">>} ->
			session_down;
		{ok, <<"response",Seq:4/signed-integer-unit:8,"delay",Delay:1/signed-integer-unit:8>>} ->
			timer:sleep(Delay*10*1000),
			gen_tcp:send(Socket,<<"keepalive",(Seq+1):4/signed-integer-unit:8,"delay",Delay:1/signed-integer-unit:8>>),
            loop(Socket,run);
        {ok, Data} ->
			timer:sleep(3000),
            gen_tcp:send(Socket, Data),
            loop(Socket,run);
        {error, closed} ->
			io:format("received error, closed~n"),
            ok
    end.
