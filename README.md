## pointfrip
**Pointfree Interpreter with Classes in Lazarus**
 
 
![screenshot](https://raw.githubusercontent.com/metazip/pointfrip/main/tahomapointfrip.png)
  
  
combinator-style like [FP](https://dl.acm.org/doi/pdf/10.1145/359576.359579) from John Backus

    ip ≡ (+ \) ° (* aa) ° trans ° ee
    eq0  ≡ id=0
    sub1 ≡ id-1
    fact ≡ eq0 → 1; id*fact°sub1

for example: generation of numbers with iota

    iota == [1]°((ispos°[0])->*(pred°[0]),([0],[1]),)°id,(),
    iota ° 10
    --> (1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ;)

possibility to work with tables like in [trivia](https://esolangs.org/wiki/FP_trivia)

    (#beta & #alpha & #gamma & #delta & "US") ° (delta:="K") ° '("A" alpha "B" beta "C" gamma)
    --> "BACKUS"

side-effects used in [installer.exe](https://github.com/metazip/pointfrip/tree/main/installer)

    ((#draco loadtext)°(draco:=corepath & "drache.pf") eff 'io)>>(it showinfo)>>(#draco run)>>()

[Reference.pdf](https://github.com/metazip/pointfrip/blob/main/examples/documents/reference.pdf) \
[Quickinfo.pdf](https://github.com/metazip/pointfrip/blob/main/examples/documents/quickinfo.pdf) (English)

### [Getting Startet ...](https://github.com/metazip/pointfrip/blob/main/Getting%20Started.md)

### Comments

If you like pointfrip, leave a comment on [discussions](https://github.com/metazip/pointfrip/discussions)
or maybe
[donate](https://pf-system.github.io/Page3.html)

\
**Virengeprüft mit 40 Virenscannern von heise.de**: [FP-trivia](https://www.heise.de/download/product/fp-trivia)
