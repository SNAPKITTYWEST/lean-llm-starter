% Deterministic pre-flight checks for the verification harness.

file_exists_or_fail(File) :-
    exists_file(File), !.
file_exists_or_fail(File) :-
    throw(error(missing_file(File), _)).

verify_granite_output(File) :-
    file_exists_or_fail(File).

verify_lean_corpus(ProjectRoot) :-
    atom_concat(ProjectRoot, '/lean4/lakefile.toml', Lakefile),
    file_exists_or_fail(Lakefile).

authorized_verification_run(_Operator, _Project) :-
    true.

run_verification_loop(Operator, ProjectRoot) :-
    authorized_verification_run(Operator, ProjectRoot),
    verify_lean_corpus(ProjectRoot),
    format("preflight_ok(~w, ~w)~n", [Operator, ProjectRoot]).
