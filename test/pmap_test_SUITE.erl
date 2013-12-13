-module(pmap_test_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include_lib("proper/include/proper.hrl").

-define(PROPTEST(A), true = proper:quickcheck(A(), [{numtests, 500}])).


suite() ->
    [{timetrap,{seconds,30}}].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, _Config) ->
    ok.

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, _Config) ->
    ok.

groups() ->
    [{t_pmap, [],
      [t_partition,
       t_map,
       t_bounded_map]}].

all() -> 
    [{group, t_pmap}].

id(E) -> E.

t_partition(_Config) ->
    ?PROPTEST(partition).

partition() ->
    ?FORALL({L, N}, {list(), integer(1, inf)},
            begin
                Partitioned = pmap:partition(L, N),
                lists:append(Partitioned) =:= L
            end).

t_map(_Config) ->
    ?PROPTEST(map).

map() ->
    ?FORALL(L, list(), pmap:map(fun id/1, L) =:= [id(E) || E <- L]).

t_bounded_map(_Config) ->
    ?PROPTEST(bounded_map).

bounded_map() ->
    ?FORALL({L, N}, {list(), integer(1, inf)},
            pmap:map(fun id/1, L, N) =:= [id(E) || E <- L]).
