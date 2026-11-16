#! /usr/bin/env bqn
e←@+27 ⋄ fr←1÷30                                                            # fr: frames per second
TermSize←{𝕊:
  t←¯1↓1⊑•SH⟨"sh","-c","stty size </dev/tty"⟩ ⋄ •BQN '‿'¨⌾((' '=t)⊸/)t
}⎊(24‿80˙)

Write ⇐ {
  𝕩
}

Eval⇐{
  𝕩
}

Render⇐{
  𝕩
}

Input⇐{
   𝕊@:𝕊•term.CharN@
;  𝕊𝕩:𝕩=e?𝕩∾e𝕊•term.CharN@
;  𝕊𝕩:𝕩<@+128?⟨𝕩⟩
;  𝕊𝕩:𝕩<@+224?•FromUTF8𝕩∾⟨•term.CharN@⟩
;  𝕊𝕩:𝕩<@+240?•FromUTF8𝕩∾⟨•term.CharN@,•term.CharN@⟩
;  𝕊𝕩:        •FromUTF8𝕩∾⟨•term.CharN@,•term.CharN@,•term.CharN@⟩
; e𝕊0:@
; e𝕊𝕩:⊑𝕩∊∾'~'∾+⟜(↕26)¨"Aa"?𝕩
; e𝕊𝕩:𝕩⋄𝕩∾e𝕊•term.CharN@
}

{⟨"watch"⟩:
  •term.RawMode 1
  •term.OutRaw e∾"[2J"                                                      # clear all
  {𝕊s0‿t0:
    w‿h ← TermSize@
    s←⟨Input@, t←•MonoTime@⟩ Eval s0
    •term.OutRaw e∾"[0;0H"                                                  # go to top
    •term.OutRaw •ToUTF8 w‿h‿t Render s
    •term.Flush@
    •Delay⍟(>⟜0) |fr-t-t0
    s‿t
  } •_while_ 1 ⟨Make@,•MonoTime@⟩
; 𝕩
}•args

