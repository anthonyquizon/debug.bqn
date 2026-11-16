#! /usr/bin/env bqn
e←@+27 ⋄ fr←1÷30 ⋄ nl←@+10                                        # fr: frames per second
TermSize←{𝕊:
  t←¯1↓1⊑•SH⟨"sh","-c","stty size </dev/tty"⟩
  •BQN '‿'¨⌾((' '=t)⊸/)t
}⎊(24‿80˙)

blocks←{
  all   ⇐ @+9600+↕32                                              # "▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟"
  lower ⇐ @+9600+1+↕8                                             # "▁▂▃▄▅▆▇█"  ⅛ → full height (bars, sparklines)
  left  ⇐ @+9608+↕8                                               # "█▉▊▋▌▍▎▏"  full → ⅛ width (horizontal bars)
  shade ⇐ " ░▒▓█"                                                 # empty → full shading
  quads ⇐ " ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█"                                      # quadrants indexed by 4-bit mask (TL=1 TR=2 BL=4 BR=8)

  # Quadrant char from booleans tl‿tr‿bl‿br
  Quad ⇐ { quads⊑˜+´1‿2‿4‿8×𝕩 }

  # ANSI SGR escapes
  e     ⇐ @+27
  Sgr   ⇐ { e∾"["∾(1↓∾";"⊸∾¨•Fmt¨𝕩)∾"m" }                         # Sgr ⟨codes…⟩
  Fg    ⇐ Sgr 38‿2∾⊢                                              # truecolor foreground: Fg r‿g‿b
  Bg    ⇐ Sgr 48‿2∾⊢                                              # truecolor background: Bg r‿g‿b
  Fg256 ⇐ Sgr 38‿5∾⊢                                              # 256-colour fg: 232–255 grey ramp, 16–231 6×6×6 cube
  Bg256 ⇐ Sgr 48‿5∾⊢
  rs    ⇐ Sgr ⟨0⟩                                                 # reset
  Half ⇐ { (Fg 𝕨)∾(Bg 𝕩)∾"▀" }                                    # Two vertical pixels in one cell: top Half bot (both r‿g‿b)
  Hue ⇐ { ⌊255×0⌈1⌊1-˜|3-˜6|0‿4‿2+6×𝕩 }                           # Hue in [0,1) → r‿g‿b (full saturation and value)
  Gradient ⇐ { a‿b𝕊n: rs∾˜∾{(Fg ⌊a+𝕩×b-a)∾"█"}¨(↕n)÷1⌈n-1 }       # a‿b Gradient n: n full blocks linearly interpolated from colour a to b
  Spectrum ⇐ { rs∾˜∾{(Hue 𝕩)Half Hue 1|𝕩+0.5}¨(↕𝕩)÷𝕩 }            # Spectrum n: rainbow of n half-block cells (hue on top, shifted hue below)

  black     ⇐ 0‿0‿0
  white     ⇐ 255‿255‿255
  grey      ⇐ 128‿128‿128
  darkGrey  ⇐ 64‿64‿64
  lightGrey ⇐ 192‿192‿192
  red       ⇐ 255‿0‿0
  darkRed   ⇐ 128‿0‿0
  green     ⇐ 0‿255‿0
  darkGreen ⇐ 0‿128‿0
  blue      ⇐ 0‿0‿255
  navy      ⇐ 0‿0‿128
  yellow    ⇐ 255‿255‿0
  cyan      ⇐ 0‿255‿255
  teal      ⇐ 0‿128‿128
  magenta   ⇐ 255‿0‿255
  purple    ⇐ 128‿0‿128
  orange    ⇐ 255‿165‿0
  pink      ⇐ 255‿192‿203
  brown     ⇐ 139‿69‿19
  gold      ⇐ 255‿215‿0
  violet    ⇐ 148‿0‿211
  skyBlue   ⇐ 135‿206‿235
  lime      ⇐ 50‿205‿50
  olive     ⇐ 128‿128‿0

  Cube ⇐ { 16++´36‿6‿1×𝕩 }
}

rename← @•FFI"i32"‿"rename"‿"*u8:c8"‿"*u8:c8"
Write ⇐ {𝕊:
  # atomic write
  d←"woo!"
  t←∾⟜".tmp"f←"/tmp/debug.data"
  t •file.Chars d
  {𝕊:•Out "Error writing output"}⍟0⊸≠ Rename t‿f∾¨@
}

Eval⇐{
  i‿t𝕊s:i≡"q"?{•Exit 0}
;   ·𝕊s:s
}

Render⇐{w‿h‿t𝕊s:
  d←3‿3‿30⥊↕30
  n←3
  ⟨red,blue⟩←blocks
  •Out red‿blue blocks.Gradient 244
  #•SHOW ≢d
  #•SHOW bl.shade ⊏˜⌊0.5+n×d÷(⌈´-⌊´)⥊d
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
  •term.OutRaw e∾"[2J"                                            # clear all
  {𝕊s0‿t0:
    w‿h ← TermSize@
    s←⟨Input@, t←•MonoTime@⟩ Eval s0
    •term.OutRaw e∾"[0;0H"                                        # go to top
    •term.OutRaw •ToUTF8 w‿h‿t Render s
    •term.Flush@
    •Delay⍟(>⟜0) |fr-t-t0
    s‿t
  } •_while_ 1 ⟨⟨⟩,•MonoTime@⟩
; 𝕩: @
}•args

