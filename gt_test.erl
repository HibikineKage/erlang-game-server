-module(gt_test).
-export([client/0,server/0]).

client() ->
    io:format("C: open connection~n",[]),
    SomeHostInNet = "localhost", % to make it runnable on one machine
    {ok, Sock} = gen_tcp:connect(SomeHostInNet, 8080,
                                 [binary, {packet, 0}]),
    receive
        {tcp, Sock, Bin} ->
            io:format("C: get ~p~n",[Bin])
    end,
    ok = gen_tcp:send(Sock, "Hello "),
    io:format("C: send data~n", []),
    ok = gen_tcp:send(Sock, "erlang"),
    io:format("C: send data~n", []),
    ok = gen_tcp:close(Sock),
    io:format("C: close~n", []).

server() ->
    {ok, LSock} = gen_tcp:listen(8080, [binary, {packet, 0}]),
    io:format("S: waiting connection~n", []),
    {ok, Sock} = gen_tcp:accept(LSock),
    io:format("S: connected~n", []),
    gen_tcp:send(Sock, "ack"),
    {ok, Bin} = do_recv(Sock, []),
    ok = gen_tcp:close(Sock),
    io:format("S: close~n", []),
    io:format("S: get data~p~n", [Bin]).

do_recv(Sock, BinList) ->
    receive
        {tcp, Sock, Bin} ->
            io:format("S: receive data~n", []),
            do_recv(Sock, [Bin | BinList]);
        {tcp_closed, Sock} ->
            {ok, lists: reverse(BinList)}
    end.
