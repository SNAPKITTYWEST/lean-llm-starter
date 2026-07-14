import Lean.Data.Json.FromToJson

namespace SovereignCorpus.Bridge

open Lean

structure ProblemMeta where
  source : String
  timestamp : String
  operatorSig : String
  maxSteps : Nat
  allowedTactics : List String
deriving Repr, Inhabited, Lean.FromJson, Lean.ToJson

structure GraniteProblem where
  id : String
  statement : String
  context : List String
  tacticHint : Option String
  meta : ProblemMeta
deriving Repr, Inhabited, Lean.FromJson, Lean.ToJson

inductive ResponseStatus where
  | proposed
  | corrected
  | failed
deriving Repr, Inhabited, Lean.FromJson, Lean.ToJson

inductive DiagnosticSeverity where
  | info
  | warning
  | error
deriving Repr, Inhabited, Lean.FromJson, Lean.ToJson

structure Span where
  startLine : Nat
  startCol : Nat
  endLine : Nat
  endCol : Nat
deriving Repr, Inhabited, Lean.FromJson, Lean.ToJson

structure Diagnostic where
  severity : DiagnosticSeverity
  message : String
  span : Option Span
deriving Repr, Inhabited, Lean.FromJson, Lean.ToJson

structure GraniteResponse where
  problemId : String
  status : ResponseStatus
  proofScript : String
  diagnostics : List Diagnostic
deriving Repr, Inhabited, Lean.FromJson, Lean.ToJson

end SovereignCorpus.Bridge
