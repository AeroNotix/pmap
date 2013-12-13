-module(pmap).

-export([map/2]).
-export([map/3]).
-export([partition/2]).

-type t() :: any().
-type transform() :: fun((t()) -> t()).


-spec map(transform(), list(A)) -> list(B) when A :: t(), B :: t().
map(F, L) when is_function(F) andalso is_list(L) ->
    Self = self(),
    Ref = make_ref(),
    Pids = [begin
                spawn(fun() ->
                              Self ! {self(), Ref, catch F(E)}
                      end)
            end || E <- L],
    gather(Pids, Ref, []).

-spec map(transform(), list(A), non_neg_integer()) ->
                 list(B) when A :: t(),  B :: t().
map(F, L, N) when is_function(F) andalso is_list(L) andalso N > 0->
    Partitioned = partition(L, N),
    lists:append([map(F, P) || P <- Partitioned]).

-spec gather(list(A), reference(), list(B)) ->
                    list(B) when A :: t(), B :: t().
gather([], _Ref, Acc) ->
    lists:reverse(Acc);
gather([H|T], Ref, Acc) ->
    receive
        {H, Ref, Result} ->
            gather(T, Ref, [Result|Acc])
    end.

-spec partition(list(A), non_neg_integer()) ->
                       list(list(A)) when A :: t().
partition(L, N) when N > 0 ->
    partition(L, N, []).

-spec partition(list(A), non_neg_integer(), list(list(A))) ->
                       list(list(A)) when A :: t().
partition([], _N, Acc) ->
    lists:reverse(Acc);
partition(L, N, Acc) ->
    {H,T} = extract_head(L, N),
    partition(T, N, [H|Acc]).

-spec extract_head(list(A), non_neg_integer()) ->
                          {list(A), list(A)} when A :: t().
extract_head(L, N) when N > 0 ->
    if
        length(L) =< N ->
            {L, []};
        true ->
            {lists:sublist(L, N), lists:nthtail(N, L)}
    end.
