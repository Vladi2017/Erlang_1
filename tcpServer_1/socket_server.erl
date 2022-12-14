-module(socket_server).
-behavior(gen_server).
%% http://20bits.com/article/erlang-a-generalized-tcp-server
-export([init/1, code_change/3, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).
-export([accept_loop/1]).
-export([start/3]).

-define(TCP_OPTIONS, [binary, inet, {packet, 0}, {active, false}, {reuseaddr, true}]).

-record(server_state, {port, loop, ip=any, lsocket=null}).

start(Name, Port, Loop) ->
	io:format("socket_server rel.10~n"),
	State = #server_state{port = Port, loop = Loop},
	gen_server:start_link({local, Name}, ?MODULE, State, []).

init(State = #server_state{port=Port}) ->
	case gen_tcp:listen(Port, ?TCP_OPTIONS) of
   		{ok, LSocket} ->
   			NewState = State#server_state{lsocket = LSocket},
   			{ok, accept(NewState)};
   		{error, Reason} ->
   			{stop, Reason}
	end.

handle_cast({accepted, _Pid}, State=#server_state{}) ->
	io:format("socket_server:handle_cast/2, State = ~w~n", [State]),
	{noreply, accept(State)}.

accept_loop({Server, LSocket, {M, F}}) -> % M,F = Module, Function
	io:format("reach server accept state~n"),
	{ok, Socket} = gen_tcp:accept(LSocket), %%Vl.blocking operation
	% Let the server spawn a new process and replace this loop
	% with the echo loop, to avoid blocking 
	case M:F(Socket,start) of
		server_down ->
			io:format("server_down~n"),
			init:stop();
		Other ->
			error_logger:info_msg("Vl3. session closed with ~w~n", [Other]),
			gen_tcp:close(Socket),
			gen_server:cast(Server, {accepted, self()})
	end.
	
% To be more robust we should be using spawn_link and trapping exits
accept(State = #server_state{lsocket=LSocket, loop = Loop}) ->
	proc_lib:spawn(?MODULE, accept_loop, [{self(), LSocket, Loop}]),
	State.

% These are just here to suppress warnings.
handle_call(_Msg, _Caller, State) -> {noreply, State}.
handle_info(_Msg, Library) -> {noreply, Library}.
terminate(_Reason, _Library) -> ok.
code_change(_OldVersion, Library, _Extra) -> {ok, Library}.
