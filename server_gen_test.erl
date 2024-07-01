-module(server_gen_test).
-include_lib("eunit/include/eunit.hrl").

calc_test() ->
    server_gen:start_link(),
    Pid = server_gen:connect(),
    ?assertEqual(27, server_gen:calculate(Pid, {add, [1, 2, {mul, [2, 3, 4]}]})),
    Pid ! exit.

throw_test() ->
    server_gen:start_link(),
    Pid = server_gen:connect(),
    ?assertEqual({error, divide_by_zero}, server_gen:calculate(Pid, {divi, [1, 0]})),
    Pid ! exit.
