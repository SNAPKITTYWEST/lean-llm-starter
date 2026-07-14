import Lean.Data.Json
import SovereignCorpus.Bridge.Granite4Schema

namespace SovereignCorpus.Bridge.Granite4Parser

open Lean
open SovereignCorpus.Bridge

inductive ParseError where
  | jsonDecode (msg : String) (line : Nat)
  | schemaViolation (field : String) (reason : String)
  | lean3SyntaxDetected (pattern : String) (line : Nat)
  | tacticForbidden (tactic : String) (line : Nat)
deriving Repr, Inhabited

def forbiddenPatterns : List String :=
  [
    "meta def",
    "tactic.block",
    "refine_struct",
    "classical.by_contradiction",
    "by_contra!",
    "have! := by",
    "sorryAx",
    "prop_decidable",
    "Classical.propDecidable"
  ]

def defaultAllowedTactics : List String :=
  ["rw", "simp_all", "norm_num", "linarith", "nlinarith", "aesop", "apply", "exact", "intro", "obtain", "cases", "induction", "constructor", "split_ifs", "field_simp", "ring_nf", "norm_cast", "omega"]

def containsText (haystack needle : String) : Bool :=
  if needle.isEmpty then
    true
  else
    (haystack.splitOn needle).length > 1

def containsForbiddenPattern (text : String) : Option String :=
  forbiddenPatterns.find? (fun pattern => containsText text pattern)

def guardLean4Syntax (p : GraniteProblem) (line : Nat) : Except ParseError Unit := do
  let haystack := p.statement ++ "\n" ++ String.intercalate "\n" p.context ++ "\n" ++ p.tacticHint.getD ""
  match containsForbiddenPattern haystack with
  | some pattern => throw <| ParseError.lean3SyntaxDetected pattern line
  | none => pure ()

def guardTactics (p : GraniteProblem) (line : Nat) : Except ParseError Unit := do
  match p.tacticHint with
  | some hint =>
      if p.meta.allowedTactics.contains hint || defaultAllowedTactics.contains hint then
        pure ()
      else
        throw <| ParseError.tacticForbidden hint line
  | none => pure ()

def guardStatement (p : GraniteProblem) : Except ParseError Unit := do
  if containsText p.statement "sorry" then
    throw <| ParseError.schemaViolation "statement" "target theorem statement must not contain sorry"
  else
    pure ()

def parseLine (line : String) (lineNum : Nat) : Except ParseError GraniteProblem := do
  if line.trim.isEmpty then
    throw <| ParseError.jsonDecode "empty line" lineNum
  let json <- Json.parse line |>.mapError (fun err => ParseError.jsonDecode err lineNum)
  let problem <- fromJson? json |>.mapError (fun err => ParseError.jsonDecode err lineNum)
  guardLean4Syntax problem lineNum
  guardTactics problem lineNum
  guardStatement problem
  pure problem

def loadProblems (path : String) : IO (Except String (List GraniteProblem)) := do
  let content ← IO.FS.readFile path
  let lines := content.splitOn "\n"
  let parsed := lines.enum.filterMap (fun ⟨idx, line⟩ =>
    if line.trim.isEmpty then
      none
    else
      some <| parseLine line (idx + 1)
  )
  let errors := parsed.filterMap (fun r => match r with | .error e => some e | .ok _ => none)
  if !errors.isEmpty then
    pure <| Except.error s!"parse failures: {repr errors}"
  else
    pure <| Except.ok <| parsed.filterMap (fun r => match r with | .ok p => some p | .error _ => none)

end SovereignCorpus.Bridge.Granite4Parser
