-module(server).
-export([connect/0, calculate/2]).

connect() ->
    spawn(fun() -> loop() end).

loop() ->
    receive
        {From, Req} when is_pid(From) ->
            try
                Res = calculate(Req),
                From ! Res
            catch
                _:Reason ->
                    From ! {error, Reason}
            end,
        loop() 
    end.


calculate(Pid, Req) -> 
    From = self(),
    try
        Pid ! {From, Req},
        receive
            Resp -> Resp
        end
    catch
        _:Reason ->
            {error, Reason}
    end.

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

