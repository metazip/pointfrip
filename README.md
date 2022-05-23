# pointfrip
**pointfree interpreter with classes in lazarus**
 
 
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

[Reference.pdf](https://github.com/metazip/pointfrip/blob/main/examples/documents/reference.pdf) \
[Quickinfo.pdf](https://github.com/metazip/pointfrip/blob/main/examples/documents/quickinfo.pdf) (german)

  
  
If you like pointfrip, leave a feedback on [pointfrip wiki](http://162.248.51.100/~pointfre/wiki/doku.php)

  or

[Donate](https://pf-system.github.io/Page3.html)


**structured programming -- a kind of low-code**

![backus-fp1](https://github.com/metazip/pointfrip/blob/main/backus-fp/backusfp1.png)
![backus-fp2](https://github.com/metazip/pointfrip/blob/main/backus-fp/backusfp2.png)


**Turing Award Lecture**

![backus-fp-adventages](https://github.com/metazip/pointfrip/blob/main/backus-fp/backusfpadvantages.png)
