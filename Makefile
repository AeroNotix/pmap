dialyze:
	dialyzer -r ebin/

deps:
	rebar get-deps

compile:
	rebar compile

test:
	rebar ct

.PHONY: \
	dialyze \
	deps \
	compile \
	test
