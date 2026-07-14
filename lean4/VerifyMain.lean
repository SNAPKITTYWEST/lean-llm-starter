import SovereignCorpus.Bridge.Granite4Parser
import SovereignCorpus.Tactics.PlasmaGate

def parseOnlyMode (args : List String) : IO UInt32 := do
  let path :=
    match args.dropWhile (fun a => a != "--parse") with
    | _ :: file :: _ => file
    | _ => "artifacts/input.jsonl"
  let problemsOrError ← SovereignCorpus.Bridge.Granite4Parser.loadProblems path
  match problemsOrError with
  | Except.ok problems =>
      IO.println s!"parse_ok:{problems.length}"
      pure 0
  | Except.error err =>
      IO.eprintln s!"parse_error:{err}"
      pure 1

def fullVerificationMode : IO UInt32 := do
  IO.println "verification harness scaffold: full verification mode not yet implemented"
  pure 0

def main (args : List String) : IO UInt32 := do
  let code ←
    if args.contains "--parse" then
      parseOnlyMode args
    else
      fullVerificationMode
  if code != 0 then
    IO.eprintln s!"verify failed with code {code}"
  pure code
