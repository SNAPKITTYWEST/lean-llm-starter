:- consult('sovereign_verification.pl').

generate_problems(Intent, MathlibCtx, OperatorSig, OutputFile) :-
    setup_call_cleanup(
        open(OutputFile, write, Stream),
        json_write_dict(Stream, _{
            id:"demo-problem-1",
            statement:Intent,
            context:MathlibCtx,
            tacticHint:"aesop",
            meta:_{
                source:"granite-4.1-verifier",
                timestamp:"2026-07-14T00:00:00Z",
                operatorSig:OperatorSig,
                maxSteps:30,
                allowedTactics:["rw","simp_all","norm_num","linarith","nlinarith","aesop","apply","exact","intro","obtain","cases","induction"]
            }
        }, [width(0)]),
        close(Stream)
    ).

call_granite(InputFile, OutputFile) :-
    setup_call_cleanup(
        open(InputFile, read, In),
        read_string(In, _, Content),
        close(In)
    ),
    setup_call_cleanup(
        open(OutputFile, write, Out),
        format(Out, "{\"problemId\":\"demo-problem-1\",\"status\":\"proposed\",\"proofScript\":\"~w\",\"diagnostics\":[]}~n", [Content]),
        close(Out)
    ).

parse_and_validate(JsonlFile, success(JsonlFile)).

%% Shell out to `lake exe verify -- --parse <file>` and capture exit code.
%% Requires SWI-Prolog shell/2. Lake must be on PATH or LAKE_BIN env set.
execute_verification(JsonlFile, Result) :-
    ( getenv('LAKE_BIN', Lake) -> true ; Lake = 'lake' ),
    atomic_list_concat([Lake, ' exe verify -- --parse ', JsonlFile], Cmd),
    ( shell(Cmd, 0) ->
        Result = result(0, verified)
    ;
        Result = result(1, parse_failed)
    ).

verify_with_retries(Intent, OperatorSig, MaxRetries, FinalResult) :-
    verify_loop(Intent, OperatorSig, 0, MaxRetries, FinalResult).

verify_loop(Intent, OperatorSig, Attempt, MaxRetries, FinalResult) :-
    Attempt < MaxRetries,
    generate_problems(Intent, ["import Mathlib"], OperatorSig, 'input.jsonl'),
    call_granite('input.jsonl', 'granite_response.jsonl'),
    parse_and_validate('granite_response.jsonl', ParseRes),
    ( ParseRes = success(_) ->
        execute_verification('granite_response.jsonl', KernelResult),
        ( KernelResult = result(0, _) ->
            FinalResult = success(KernelResult),
            post_verified(Intent, OperatorSig)
        ; NextAttempt is Attempt + 1,
          verify_loop(Intent, OperatorSig, NextAttempt, MaxRetries, FinalResult)
        )
    ; NextAttempt is Attempt + 1,
      verify_loop(Intent, OperatorSig, NextAttempt, MaxRetries, FinalResult)
    ).

%% Fire mastodon_poster.py on successful verification.
post_verified(Intent, OperatorSig) :-
    atomic_list_concat([
        'python3 ../infra/mastodon_poster.py',
        ' --problem-id "', OperatorSig, '"',
        ' --theorem "', Intent, '"'
    ], Cmd),
    ( shell(Cmd, 0) ->
        format("mastodon_post:ok~n")
    ;
        format("mastodon_post:failed (non-fatal)~n")
    ).

verify_loop(_, _, Attempt, MaxRetries, fail(max_retries_exceeded)) :-
    Attempt >= MaxRetries.
