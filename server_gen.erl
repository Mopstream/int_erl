-module(server_gen).
-behaviour(gen_server).

-export([start_link/0, connect/0, calculate/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

connect() ->
    gen_server:call(?MODULE, connect).

calculate(Pid, Req) ->
    gen_server:call(Pid, {calculate, Req}).



init([]) ->
    {ok, #state{}}.

handle_call(connect, _From, State) ->
    {reply, self(), State};

handle_call({calculate, Req}, _From, State) ->
    try
        Result = calculate(Req),
        {reply, Result, State}
    catch
        _:Reason ->
            {reply, {error, Reason}, State}
    end.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

calculate(Req) ->
    case Req of
        {add, Args} when is_list(Args) -> lists:foldl(fun(X, Acc) -> calculate(X) + Acc end, 0, Args);
        {mul, Args} when is_list(Args) -> lists:foldl(fun(X, Acc) -> calculate(X) * Acc end, 1, Args);
        {sub, Args} when is_list(Args) -> lists:foldl(fun(X, Acc) -> calculate(X) - Acc end, 0, Args);
        {divi, Args} when is_list(Args) -> 
            try lists:foldl(fun(X, Acc) -> Acc / calculate(X) end, 1, Args)
            catch _:_ -> {error, divide_by_zero} end;
        X when is_number(X) -> X
    end.
