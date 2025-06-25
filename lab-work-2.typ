#import "@preview/wrap-it:0.1.0": wrap-content

#let e = "ë"
#let c = "ç"

#let index-of(el, kind: none) = {
  if kind == none {
    kind = el.func()
  }
  numbering(el.numbering, ..counter(kind).at(el.location()))
}
#let ref-link(el, prefix: "", kind: none) = link(el.location(), prefix + index-of(el, kind: kind))

#let content-to-string(c) = {
  if c.has("text") {
    c.text
  } else if c.has("children") {
    c.children.map(content-to-string).join()
  } else if c.has("body") {
    content-to-string(c.body)
  } else if c == [ ] {
    " "
  }
}

#set math.equation(numbering: "(1)")
#set page(paper: "a4", margin: (x: 75pt, y: 45pt))
#set heading(numbering: "1.1")
#show ref: it => {
  let el = it.element
  if el != none and el.func() == math.equation {
    ref-link(el)
  } else if el.func() == figure {
    ref-link(el, prefix: "Fig. ", kind: figure.where(kind: el.kind))
  } else if el.func() == table {
    ref-link(el, prefix: "Tabela ")
  } else if el.func() == heading {
    link(
      el.location(),
      content-to-string(el).split(".").at(0)
    )
  } else {
    it
  }
}
#show figure.caption: it => {
  context {
    let n = it.counter.display(it.numbering)
    let supplement = if it.kind == image {
        "Figura"
      } else if it.kind == table {
        "Tabela"
      } else {
        it
      }

    if repr(it.body) == "[]" {
      [#supplement #(n)]
    } else {
      [#supplement #(n)#(it.separator)#it.body]
    }
  }
}

#figure(
  image("./priv/upt.png", width: 35%)
)

#let metadata = (
  author: "Filan Fisteku",
  teacher: "Dr. Aqif Kopertoni",
  location: "Kamëz",
  school-year: "2024-2025",
  university: "I KAMËZËS",
  faculty: "I PESHKIMIT",
  degree: "PESHKIM",
  class: (
    number: 1,
    group: "F"
  )
)
// #let metadata = json("metadata.json")

#align(center)[
  #text(20pt, font: "Times New Roman", weight: "bold")[
    UNIVERSITETI #metadata.university \
    FAKULTETI #metadata.faculty \
    DEGA: #metadata.degree #metadata.class.number#super(metadata.class.group)
  ]

  #text(40pt, font: "Times New Roman", weight: "bold")[
    PUNË LABORATORI
  ]

  #pad(top: 80pt)[
    #text(20pt, font: "Times New Roman", weight: "bold")[
      LËNDA: FIZIKË 2
    ]
  ]

  #pad(top: 120pt)[
    #text(15pt, font: "Times New Roman", weight: "bold")[
      Punoi: #metadata.author #h(1fr) Pranoi: #metadata.teacher
    ]
  ]

  #align(bottom)[
    #text(25pt, font: "Times New Roman", weight: "bold")[
      #metadata.location #metadata.school-year
    ]
  ]
]

#pagebreak()
#counter(math.equation).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)
#set math.equation(numbering: "(1)")

#let diffrac(a, b, n: 1) = if n == 1 {
  $frac(upright(d) #a, upright(d) #b)$
} else {
  $frac(upright(d)^#n #a, upright(d) #b^#n)$
}

#let d1 = json("exercise-results/exercise-11/data.json")
= Induksioni Elektromagnetik

== Teoria e punës

Fluksi i induksionit magnetik nëpër një sipërfaqe të kufizuar nga një kontur i mbyllur përcjellës, quhet madhësia skalare $Phi$:
$
  Phi = B S cos theta
$
Ku $S$ është sipërfaqja e konturit the $theta$ këndi midis normales ndaj planit të konturit dhe vektorit të induksionit magnetik $B$. Pra shpejtësia e ndryshimit të fluksit magnetik jepet nga:
$
  (Delta Phi) / (Delta t) = (Delta B) / (Delta t) S
$
Rezultati i punës së Faradeit ishte zbulimi i *ligjit të induksionit elektromagnetik të Faradeit*, i cili lidh tensionin apo f.e.m e induktuar që lind në konturin e mbyllur me shpejtësinë e ndryshimit të fluksit magnetik:
$
  epsilon_"ind" = U = - diffrac(Phi, t)
$ <induced-voltage-formula>
Ku $U$ është vlera mesatare e tensionit të induktuar gjatë intervalit të kohës $Delta t$. Vihet re që:
$
  diffrac(Phi, t) = diffrac(B, t) S + diffrac(S, t) B
$ <flux-diff-eq>

D.m.th fluksi mund të ndryshojë për shkak të ndryshimit të fushës magnetike $diffrac(B, t) S$, nëpër një kontur me sipërfaqe të pandryshueshme, ose për shkak të ndryshimit të sipërfaqes së konturit $diffrac(S, t) B$, në një fushë magnetike të pandryshueshme. Në të dy rastet, numri apo denduria i vijave të fushës që përshkojnë konturin (fluksi magnetik), ndryshon. Efekti i dytë zakonisht përftohet duke rrotulluar një kontur përcjellës në një fishë magnetike konstante, kështu që sipërfaqja "efektive" e koturit që presin vijat e fushës, pra dhe fluksi ndryshon. Në këtë punë laboratori do të përqëndrohemi vetëm në efektin e termit të parë të ekuacionit @flux-diff-eq, pra në ndryshimin e fluksit për shkak të ndryshimit të induksionit të fushës magnetike. Shenja minus në ekuacionin @induced-voltage-formula shpreh një tjetër ligj të rëndësishëm të induksionit elektromagnetik, *ligjin e Lencit*, i cili jep drejtimin e rrymës së induktuar.

#figure(
  image("./exercise-results/exercise-11/diagram-1.jpg", height: 20%),
)

Në thelb, kjo do të thotë që rryma e induktuar krijon një fushë magnetike që kundërshton ndryshimin e fushës magnetike origjinale. Në qoftë se nuk do të ishte kështu dhe fusha magnetike e krijuar nga rryma e induktuar do ta përforconte fushën fillestare (d.m.th do të ishte në të njëjtin drejtim me fushën fillestare), fusha e induktuar do ta rriste fluksin, i cili do të rriste rrymën, e cila nga ana e saj do të rrishte përsëri fluksin dhe kështu vazhdimisht. Pra do të krijohej një situatë ku do të përftonim *diçka nga asgjëja*, gjë që bie në kundërshtim me ligjin e ruajtjes së energjisë.

Një mënyrë tjetër për të përftuar një fushë magnetike që ndryshon me kohën, dhe pra një tension të induktuar në një kontur të palëvizshëm përcjellës, është që të ndryshojmë rrymën në konturin me rrymë afër tij. Kur çelësi në qarkun A mbyllet, rryma në kontur rritet brenda një kohe të shkurtër nga zero në deri në një vlerë konstante. Gjatë kësaj edhe fusha që shoqëron këtë rrymë gjithashtu rritet ose ndryshon me kohën.

Fluksi magnetik që përshkon një kontur afër të parit gjithashtu ndryshon me kohën dhe një rrymë e induktuar rrjedh në konturin e dytë (B), gjë që e tregon shmangja e galvanometrit. Rryma e induktuar bëhet zero kur rryma në qarkun me bateri arrin vlerën konstante. Në mënyrë të ngjashme, kur çelësi hapet, fusha magnetike zvogëlohet dhe në qarkun B me galvanometër lind për një çast një rrymë në kah të kundërt me rrymën e induktuar në rastin e parë.

Në qoftë se në qarkun me galvanometër ka $N$ konture, ndryshimi i fluksit në çdo kontur kontribuon në rrymën apo tensionin e induktuar dhe ligji i Faradeit shkruhet:
$
  epsilon_"ind" = U = -N (Delta Phi) / (Delta t)
$

Sistemi i përbërë nga shumë spira teli të mbështjella ngjitur me njëra-tjetrën quhet *solenoid* ose bobinë.

Tregohet që fusha magnetike e krijuar nga rryma që rrjedh në një bobinë të gjatë (bobina primare), afër saj dhe gjatë boshtit të bobinës jepet nga:
$
  B = mu_0 n l
$
ku $n$ është numri i spirave për njësinë e gjatësisë $N slash l$ ku $l$ është gjatësia e bobinës, $mu_0 = 4 pi 10^-7 N/A^2$ është konstantja magnetike.

Në qoftë se në bobinën e gjatë primare me $N_1$ spira rrjedh rrymë alternative që ndryshon me frekuencën rrethore $omega$, e formës $I = I_0 sin omega t$, forca elektromotore e induktuar në bobinën dytësore me $N_2$ spira dhe seksion $S$ është:
$
  epsilon_"ind" &= -N_2 diffrac(Phi, t) = -N_2 diffrac(, t) B S = -N_2 mu_0 N_1/l S diffrac(I, t) \
  epsilon_"ind" &= -mu_0 N_2 S N_1 omega I_0/l cos omega t
$ <expanded-induced-voltage-formula>
Nga formula @expanded-induced-voltage-formula duket që f.e.m e induktuar në bobinën dytësore, për shkak të fenomenit të induksionit elektromagnetik, është në përpjesëtim të drejtë me intensitetin e rrymës në bobinën primare $I_0$, me frekuencën e ndryshimit të kësaj rryme $omega$ ($omega = 2pi f)$, me numrin e spirave të bobinave primare dhe dytësore dhe seksionin tërthor të tyre.

Në këtë punë laboratori do të studiohet fenomeni i induksionit elektromagnetik dhe varësia e f.e.m apo tensionit të induktuar, në varësi të intensitetit të rrymës në bobinën primare, frekuencës, numrit të spirave dhe seksionit tërthor.

== Pjesa eksperimentale

=== Pajisjet që do përdoren dhe përshkrimi i tyre

Si bobinë primare përdoret bobina me gjatësi $l = 75 "cm"$ dhe numër spirash për njësi të gjatësisë $n = 465 "spira" slash "m"$ (pra $N_1 = n l$).

Si bobina dytësore përdoren disa bobina me numër të ndryshëm spirash për njësi të gjatësisë ($100$, $200$, $300$), dhe me diametër (pra dhe seksione) të ndryshëm $d$ ($26 "mm"$, $32 "mm"$, $41 "mm"$).

në mënyrë që në bobinën primare të kalojnë rryma me intensitete dhe frekuenca të ndryshme, përdoret gjeneratori i frekuencave me diapazon frekuencash $0.1 space dash space 100 "kHz"$. Frekuenca e ndryshimit të rrymës matet me një numërues shifror. Gjeneratori i frekuencave dhe numëruesi shifror lidhen me rrjetin me tension $220 upright(V)$ dhe frekuencë $50 "Hz"$ dhe ndryshimi i frekuencave bëhet me anë të çelësit përkatës.

#pagebreak()

== Ushtrimi 1. Varësia e _f.e.m_ të induktuar $epsilon_"ind"$ nga rryma në bobinën primare.

Vendoset në gjeneratorin e frekuencave një frekuencë e caktuar që matet me anën e numëruesit shifror dhe që mbahet e pandryshueshme gjatë këtij eksperimenti.

Duke rrotulluar dorezën, ndryshohet rryma në bobinën primarë dhe vlera e rrymës matet me anë të ampermetrit. Futet brenda bobinës primare një bobinë dytësore me diametër dhe numër spirash të caktuar. F.e.m e induktuar në bobinën dytësore matet me anë të multimetrit që përdoret si voltmetër. Përsëritet procedura, duke bërë një seri matjesh (jo më pak se $10$) dhe me vlerat e përftuara ndërtohet grafiku i varësisë së $epsilon_"ind"$ nga rryma $I$.
$
  a &= (sum (I - overline(I)) (epsilon_"ind" - overline(epsilon_"ind"))) / (sum (I - overline(I))^2) \
  a &= #calc.round(d1.at(0).a, digits: 6) \ \
  b &= overline(epsilon_"ind") - a overline(I) \
  b &= #calc.round(d1.at(0).b, digits: 6)
$

#figure(
  image("./exercise-results/exercise-11/plot-1.jpg", width: 80%),
  caption: [
    Varësia e f.e.m të induktuar $epsilon_"ind"$ nga rryma $I$.
  ]
) <diag-1>

== Ushtrimi 2. Varësia e _f.e.m_ të induktuar $epsilon_"ind"$ nga frekuenca e ndryshimit të rrymës.

Mbahet konstant intensiteti $I$ i rrymës në bobinën primare dhe ndryshohet frekuenca. Për çdo rast lexohet $epsilon_"ind"$ në voltmetër. Duhet patur parasysh që ndryshimi i frekuencës ndryshon dhe intensitetin e rrymës në bobinën primare, prandaj pas ndryshimit të çdo vlere të frekuencës, rivendoset vlera konstante e intensitetit të rrymës dhe pastaj lexohet $epsilon_"ind"$. Përsëriten matjet për jo më pak se $10$ vlera, dhe me vlerat e përftuara ndërtohet grafiku i varësisë së $epsilon_"ind"$ nga frekuenca e ndryshimit të rrymës në bobinën primare.
$
  a &= (sum (f - overline(f)) (epsilon_"ind" - overline(epsilon_"ind"))) / (sum (f - overline(f))^2) \
  a &= #calc.round(d1.at(1).a, digits: 6) \ \
  b &= overline(epsilon_"ind") - a overline(f) \
  b &= #calc.round(d1.at(1).b, digits: 6)
$

#figure(
  image("./exercise-results/exercise-11/plot-2.jpg", width: 80%),
  caption: [
    Varësia e f.e.m të induktuar $epsilon_"ind"$ nga frekuenca e ndryshimit të rrymës $f$.
  ]
) <diag-2>

== Ushtrimi 3. Varësia e _f.e.m_ të induktuar $epsilon_"ind"$ nga numri i spirave të bobinës dytësore. <11-ex-3>

Me anë të gjeneratori, vendoset në bobinën primare një rrymë me intensitet dhe frekuencë të caktuar që mbahet konstante. Futen në bobinën primare disa bobina dytësore me diametër (seksion) të njëjtë, por me numër spirash të ndryshëm. Lexohet për çdo rast $epsilon_"ind"$ dhe me vlerat e përftuara ndërtohet grafiku i varësisë $epsilon_"ind"$ si funksion i numrit të spirave.
$
  a &= (sum (N_2 - overline(N_2)) (epsilon_"ind" - overline(epsilon_"ind"))) / (sum (N_2 - overline(N_2))^2) \
  a &= #calc.round(d1.at(2).a, digits: 6) \ \
  b &= overline(epsilon_"ind") - a overline(N_2) \
  b &= #calc.round(d1.at(2).b, digits: 6)
$

#figure(
  image("./exercise-results/exercise-11/plot-3.jpg", width: 80%),
  caption: [
    Varësia e f.e.m të induktuar $epsilon_"ind"$ nga numri i spirave të bobinës dytësore $N_2$.
  ]
) <diag-3>

== Ushtrimi 4. Varësia e _f.e.m_ të induktuar $epsilon_"ind"$ nga diametri i spirave të bobinës.

Veprohet njëlloj si te @11-ex-3, me ndryshimin që në këtë rast bobinat dytësore zgjidhen me numër të njëjtë spirash, por me diametra (seksione) të ndryshëm. Me vlerat e lexuara ndërtohet grafiku i varësisë së $epsilon_"ind"$ si funksion i diametrit të bobinave.

Grafikët e ndërtuar në të katër ushtrimet të analizohen me metodën e regresit linear.
$
  a &= (sum (D - overline(D)) (epsilon_"ind" - overline(epsilon_"ind"))) / (sum (D - overline(D))^2) \
  a &= #calc.round(d1.at(3).a, digits: 6) \ \
  b &= overline(epsilon_"ind") - a overline(D) \
  b &= #calc.round(d1.at(3).b, digits: 6)
$

#figure(
  image("./exercise-results/exercise-11/plot-4.jpg", width: 80%),
  caption: [
    Varësia e f.e.m të induktuar $epsilon_"ind"$ nga diametri i spirave të bobinës $D$.
  ]
) <diag-4>

#pagebreak()
#counter(math.equation).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)
#set math.equation(numbering: "(1)")

// #let d2 = json("exercise-results/exercise-12/data.json")
= Matja e frekuencës së rrymës alternative me anën e sonometrit

Qëllimi i punës është matja e frekuencës së rrymës alternative.
Rryma alternative është rryma që ndryshon sipas ligjit sinusoidal në trajtën:
$
  I = I_0 cos(omega t + alpha)
$
ku $omega$ është frekuenca rrethore që përcaktohet:
$
  omega = 2pi f
$
ku $f$ është frekuenca e ndryshimit të rrymës alternative në qark (shkurt frekuenca e rrymës). Me $I_0$ do të shënojmë amplitudën e rrymës (domethënë vlera më e madhe e rrymës në qark), kurse $alpha$ është faza fillestare.

== Parimi i punës

#figure(
  image("./exercise-results/exercise-12/diagram-1.png", height: 20%),
)

Mbi një sonometër S vendosim një tel barki, i cili fiksohet në një skaj V dhe mbështetet në dy pika të vogla A dhe B të palëvizshme. Midis pikave A dhe B është dhe një pikë K e lëvizshme. Teli i bakrit kalon nëpër një makara R dhe përfundon në një pjatë që mban pesha. Në pikat A dhe B të telit mund të aplikojmë një tension të rrymës alternative (këtë tension e marrim nga priza duke vendosur edhe një llambë në seri, rrethi, rreth $40 "Wat"$). Vendosim mbi sonometër një magnet në formë patkoi në mënyrë të tillë që teli të ndodhet ndërmjet dy degëve të magnetit duke pasur mirë parasysh që ai të mos e prekë magnetin. E vendosim pykën K në sonometër dhe shohim se për një farë pozicioni të $n$-së, pjesa AK e telit fillon të lëkunded. Magneti M vepron me një forcë të caktuar mbi telin në të cilin kalon rryma alternative. Meqënëse rryma ndryshon kahun në telin AB me një frekeuncë $f$, po ashtu do të ndryshojë dhe forca që vepron mbi telin e drejtuar një herë lart dhe një herë poshtë me të njëtjën frekuencë. Meqënëse teli AB është i fiksuar në skaje, atëherë lëkundja që lind pranë magnetit përhapet gjatë telit, pasqyrohet në skajin B dhe duke u mbledhur me lëkundjen që lind jep një valë të qëndrueshme në telin AB. Valës së qëndrueshme (stacionare) ne mund ta matim gjatësinë e valës dhe këtej mund të përcaktojmë frekuencën e lëkundjes që është sa frekuenca e rrymës alternative. Që të gjejmë frekuencën e rrymës alternative duhet të dimë formulën që lidh frekuencën e lëkundjeve që vendosen në telin AB me tensionin P, e cila është:
$
  f = n/(2l_n) sqrt(P/rho)
$ <wire-frequency-formula>

Marrim në shqyrtim lëkundjen e telit që ndodhet ndërmjet dy nyjeve. Meqënëse teli lëkunded sipas një drejtimi (drejtimi vertikal), ne këtë lëkundje formalisht mund ta mendojmë si një lëvizje rrethore rreth boshtit ox me shpejtësi këndore $omega$.

Shqyrtojmë elementin e telit midis pikave $x$ dhe $x + upright(d)x$. Në fundet e këtij elementi vepron forca e tensionit $P$, që ne do të marrim konstante (që nuk varen nga $x$). Shumica e projeksioneve të këtyre forcave në drejtimin oy do të jetë:
$
  P sin alpha(x + upright(d)x) - P sin alpha(x) tilde.equiv P t g alpha(x + upright(d) x) - P t g alpha(x)
$
Meqënëse $sin alpha(x) tilde.equiv tan alpha$ ($x$ për lëkundje të vogla), por $tan alpha = diffrac(y, x)$ atëherë do të përfitohet shprehja:
$
  P (lr(diffrac(y, x) bar.v)_(x + upright(d)x) - lr(diffrac(y, x) bar.v)_x) = P diffrac(y, x, n: 2) upright(d)x
$

Është e qartë se kjo shprehje nuk është gjë tjetër vetëm se forca centripete, meqënëse kemi lëvizje rrethore. Atëherë për pjesën e marrë në shqyrtim, forca centripete shkruhet:
$
  rho upright(d)l omega^2 y approx rho omega^2 y upright(d)x
$

Ekuacioni shkruhet në analogji me $F_c = m omega^2 R$, ku $m = rho upright(d)x$, $R=y$ dhe $upright(d)l$ është gjatësia e elementit të telit që afërsisht është e barabartë me $upright(d)x$ dhe $rho$ është densiteti linear i telit.
$
  -P diffrac(y, x, n: 2) = rho omega^2 y
$
Shenja ($-$) është e lidhur me faktin që ana e majtë e formulës @wire-frequency-formula të barazohen me forcën centripete që ka kah të kundërt me boshtin oy.

Zgjidhja e ekuacionit @wire-frequency-formula është:
$
  y = y_0 sin k x
$

Për të gjetur vlerën e $k$ arsyetojmë kështu: në secilën nyje kemi $y=0$ dhe nga barazimi $sin k x = 0$, nxjerrim që $k x = 0, pi dots.h n pi$.
Për nyjen e parë merret $x=0$ dhe $sin k x = 0$. Duke shënuar me $l$ gjatësinë e një barku përcaktohet në çdo rast:
  - Për nyjen e dytë $x=l$. Në këtë rast $sin k l = 0$ për këndin $k l = pi$, nxirret $k = pi slash l$.
  - Për nyjen e tretë $x = 2l$. Në këtë rast $sin k 2l = 0$ për këndin $k 2l = 2 pi$, nxirret $k = pi slash l$.
  - Për $x = n l$. Në këtë rast $sin k n l = 0$ për këndin $k n l = n pi$

Vihet re që në te gjitha rastet vlera e $k$ është e njëjtë. Zgjidhja në këtë rast shënohet:
$
  y = y_0 sin(pi/l x) \ =>
  P (pi/l)^2 y_0 sin(pi/l x) &= rho omega^2 y_0 sin(pi/l x) \
  P (pi/l)^2 &= rho omega^2 \
  P/rho (pi/l)^2) &= omega^2
$

Nga veprimet përcaktohet shprehja për shpejtësinë këndore të telit që rrotullohet:
$
  omega = pi/l sqrt(P/rho)
$

Çdo rrotullim me shpejtësi këndore konstante mund të përfytyrohet si shumë e dy lëkundjeve pingule harmonike me frekuencë:
$
  f = omega/(2pi) = I/(2l) sqrt(P/rho)
$
// TODO: Diagram here

Në varësi nga tensioni $P$, do të na formohen një numër i caktuar barqesh, ku kemi dy barqe dhe tri nyje. Meqënëse barqet janë krejtësisht të njëjta, atëherë në qoftë se do të matnim gjatësinë $"AK" = I_2$ për dy barqe, atëherë formula do të shkruhej:
$
  f = 2/(2l_2) sqrt(P/rho)
$

Në rastin e përgjithshëm për $n$ barqe do të shkruanim:
$
  f = n/(2l_n) sqrt(P/rho)
$

== Pjesa eksperimentale

1. Pasi të vendoset në pjatë një peshë $P$ gjejmë me anë të pykës K pozicionin e parë ku fillon të lëkunded teli, në këtë rast $n=1$. Matet gjatësia e telit të pjesës $"AK" = I_1$.
2. Zhvendoset pyka K dhe përcaktohen pozicionet e reja një e nga dhe më pas plotësohet tabela. Sonometër ku fillon të lëkundet teli dhe matet $l_2$ për të cilën $n=2$, $l_3$ për të cilën $n=3$ e kështu me radhë.
3. Përseritet eksperimenti 1 dhe 2 me pesha të ndryshme, duke i vendosur ato me radhë.

#let d2 = json("exercise-results/exercise-12/data.json")

// #align(center, box(width: 90%, figure(
//   table(
//     columns: (auto, auto, auto, auto, auto, auto, auto),
//     align: center,
//     inset: 10pt,
//     table.header([], [], $n$, [1], [2], [3], [4]),
//     $m$, $P$, [], table.cell([$l_n$ (mes)], colspan: 4),
//     ..d2.l_n-table.map(x => {
//       let (m, P, ls) = x
//       ls = ls.map(l => $#calc.round(l, digits: 4) "cm"$)
// 
//       ($#m upright(g)$, $#P upright(N)$, [], ..ls)
//     }).flatten()
//   ),
//   caption: [$l_n$ e matur]
// )))

#let fmtf(f) = if f == 0 [-] else [$#calc.round(f, digits: 4) "Hz"$]
#let fmtl(l) = if l == 0 [-] else [$#calc.round(l, digits: 4) "cm"$]
#let fmtxyz((i, (x, l))) = if l == 0 [-] else [#text($#(i+1) / (2 dot #calc.round(l / 100, digits: 4)) = $, size: 15pt) $#calc.round(x, digits: 4)$]

#for (m, P, sqrtp, ls, ndiv2ls, fs) in d2.table [
  $m &= #m upright(g) \
   P &= #P upright(N) \
   text(sqrt(P/rho) &= sqrt(#P/(#(d2.rho) dot 10^(-3))), size: #15pt) = #calc.round(sqrtp, digits: 4) space upright(s)^(-1)$
  
  #align(center, box(width: 100%, figure(
    table(
      columns: (auto, auto, auto, auto),
      align: center + horizon,
      inset: 10pt,
      table.header($n$, [$l_n$ (mes)], text($n/(2l_n)$, size: 15pt), text($f = n/(2l_n) sqrt(P/rho)$, size: 15pt)),
      ..ls.zip(ndiv2ls, fs).enumerate().map(((i, (l, x, f))) => {
        ($#(i+1)$, fmtl(l), fmtxyz((i, (x, l))), fmtf(f))
      }).flatten(),
      // ..ndiv2ls.zip(ls).enumerate().map(fmtxyz),
      // ..fs.map(fmtf)
    ),
  )))
]

// #for (m, P, fs) in d2.f-table [
//   $m = #m upright(g)$ ; $P = #P upright(N)$
//   
//   #align(center, box(width: 90%, figure(
//     table(
//       columns: (auto, auto, auto, auto, auto),
//       align: center,
//       inset: 10pt,
//       table.header($n$, [1], [2], [3], [4]),
//       $f$, ..fs.map(f => $#calc.round(f, digits: 4) "Hz"$)
//     ),
//   )))
// ]

// #align(center, box(width: 90%, figure(
//   table(
//     columns: (auto, auto, auto, auto, auto, auto, auto),
//     align: center,
//     inset: 10pt,
//     table.header([], [], $n$, [1], [2], [3], [4]),
//     $m$, $P$, [], table.cell(text($f = n/(2l_n) sqrt(P/rho)$, size: 15pt), colspan: 4),
//     ..d2.f-table.map(x => {
//       let (m, P, fs) = x
//       fs = fs.map(fmtf)
// 
//       ($#m upright(g)$, $#P upright(N)$, [], ..fs)
//     }).flatten()
//   ),
//   caption: [$f$ e llogaritur]
// )))

#pagebreak()
#counter(math.equation).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)
#set math.equation(numbering: "(1)")

= Përcaktimi i përbërëses horizontale të induksionit të fushës magnetike të Tokës

== Teoria e punës
// TODO: Diagram here
#enum(numbering: "a)")[
  + *Fusha magnetike e Tokës*

    Toka mund të konsiderohet si një sferë gjigante e magnetizuar. Në çdo pikë të sipërfaqes dhe hapësirës rreth saj ekziston fushë magnetike. Polet magnetike të Tokës nuk përputhen me polet gjeografike të saj.

    Plani i përcaktuar nga një vijë induksioni e kësaj fushe nga qendra e Tokës quhet plani i meridianit magnetik. Po të vendosim një gjilpërë magnetike në një pikë A të hapësirës, pranë Tokës, ajo do të orientohet sipas tangentes së hequr me vijën e induksionit që kalon në këtë pikë. Në ekuatorin magnetik, kjo gjilpërë do të vendoset paralelisht me sipërfaqen e Tokës, ndërsa në çdo pikë tjetër ajo do të formojë një kënd $theta$ me drejtimit horizontal. Në gjerësinë gjeografike ku ndodhet vendi ynë, një gjilpërë magnetike e varur në një fije, po të lihet e lirë, zë një pozicion si në FIGUREN 1.

    Si rrjedhojë induksioni i fushës magnetike $B$ në një pikë ka dy përbërëse, një sipas drejtimit vertikal $B_V$ dhe një tjetër sipas drejtimit horizontal $B_H$. Në këtë punë laboratori ne do të përcaktojmë përbërësen horizontale të fushës magnetike të Tokës $B_H$.

  + *Fusha magnetike e një përcjellësi rrethor me rrymë*

    Në bazë të ligjit Bio - Savar - Laplas, intensiteti i fushës magnetike i krijuar nga një element me rrymë në një pikë të hapësirës, jepet nga shprehja:
    $
      upright(d)arrow(H) = 1/(4pi) I (upright(d)arrow(l) x arrow(r)) / r^3
    $
    ku:
      - $I$: intensiteti i rrymës
      - $arrow(upright(d)l)$: gjatësia e elementit me rrymë
      - $arrow(r)$: rrezja vektore nga elementi tek pika ku kërkohet fusha

    Për një përcjellës me formë të çfarëdoshme intensiteti i plotë i fushës së krijuar në një pikë llogaritet si shumë vektoriale e intensiteteve të elementëve të veçantë të tij. Pra:
    $
      arrow(H) = sum upright(d)arrow(H)
    $

    Duke u bazuar në këtë ligj mund të llogaritet intensiteti i fushës magnetike në qendër të përcjellësit rrethor me rreze $R$, kur në të rrjedh rryma me intensitet $I$, dhe pastaj induksioni $B$ sipas formulës:
    $
      B_l = (mu_0 I)/(2 R)
    $
    ku $mu_0 = 4 pi dot 10^-7 "H/m"$ (henri/metër), është konstantja magnetike në boshllëk. Njësia e induksionit në sistemin SI është Tesla (T).

    Në qoftë se do të kishim $N$ përcjellësa të tillë rrethorë të puthitur me njëri-tjetrin në të cilët rrjedh rrymë në të njëjtin drejtim, induksioni i $B_l$ në qendër të tyre do të ishte $N$ herë meë i madh, pra:
    $
      B_l = (mu_0 I N)/(2 R)
    $ <coil-magnetic-field-formula>

    Drejtimi i kësaj fushe përcaktohet me rregullën e dorës së djathtë.
]

== Pjesa eksperimentale

=== Përshkrimi i aparaturës

Në qendër të një sistemi të përbërë nga $1$ përcjellës (ose $N$ përcjellësa), të vendosur në planin vertikal, vendoset horizontalisht një gjilpërë magnetike: të fushës $B_l$ të përcjellësit rrethor (ose përcjellësave rrethorë) dhe atë të $B_H$ të fushës magnetike të Tokës. Në qoftë se pozicioni i sistemit të përcjellësave rrethorë është i tillë që induksioni i fushës magnetike të krijuar prej tyre ($B_l$) është pingul me përbërësen horizontale të fushës magnetike të Tokës $B_H$, atëherë gjilpëra do të orientohet sipas fushës magnetike rezultante $B_R$. Shënojmë me $alpha$ këndin e formuar midis vektorëve $arrow(B_R)$ dhe $arrow(B_H)$. Kemi:
$
  B_l/B_H &= tan alpha \
  B_H &= B_l/(tan alpha)
$

Duke zëvendësuar $B_l$ nga formula @coil-magnetic-field-formula marrim:
$
  B_H = (mu_0 I N)/(2 R tan alpha)
$ <earth-magnetic-field-formula>

#pagebreak()

== Ushtrimi 1. Përcaktimi i induksionit $B_H$

1. Që të mund të zbatojmë formulën @earth-magnetic-field-formula, duhet që induksioni $arrow(B_l)$ i fushës së krijuar nga përcjellësat rrethorë të jetë pingul me përbërësen horizontale të fushës së Tokës $arrow(B_H)$, pra plani i përcjellësave duhet të përputhet me planin e meridianit magnetik, që kalon në pikën $0$.
2. Mbyllim çelësin dhe nëpërmjet reostatit vendosen vlera të ndryshme të intensitetit të rrymës në qark. Për çdo vlerë të rrymës lexojmë në busull këndin $alpha$ dhe nëpërmjet formulës @earth-magnetic-field-formula llogaritim $B_H$. Ndërrojmë drejtimin e rrymës në të kundërt dhe përsëriten matjët. Pas llogaritjeve plotësojmë tabelën.

#let d3 = json("exercise-results/exercise-15/data.json")

$
  B_l &= I mu_0/(2 R) \
  mu_0/(2 R) &approx #calc.round(d3.mudiv2R * 1e5, digits: 4) dot 10^(-5) space "H/m"^2 \
  B_l &approx I dot #calc.round(d3.mudiv2R * 1e5, digits: 4) dot 10^(-5) \
  B_H &= B_l/(tan alpha) \
  B_H &= I mu_0/(2 R) 1 /(tan alpha) \
  B_H &approx I/(tan alpha) #calc.round(d3.mudiv2R * 1e5, digits: 4) dot 10^(-5)
$

#align(center, box(width: 100%, figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: center,
    inset: 10pt,
    table.header(
      [Nr.], $I$, $alpha_1$, $tan alpha_1$, $I/(tan alpha_1)$, $B_l$, $B_H$,
    ),
    ..d3.alpha-1.enumerate().map(((i, x)) => {
      let I = x.I
      let value = x.value
      let B_l = calc.round(x.B_l * 1e6, digits: 4)
      let B_H = calc.round(x.B_H * 1e6, digits: 4)
      (
        $#(i+1)$,
        $#I upright(A)$,
        $#value degree$,
        $#calc.round(x.tan, digits: 5)$,
        $#calc.round(x.Idivtan, digits: 5)$,
        $#B_l dot 10^(-6) space upright(T)$,
        $#B_H dot 10^(-6) space upright(T)$
      )
    }).flatten()
  )
)))

#align(center, box(width: 100%, figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: center,
    inset: 10pt,
    table.header(
      [Nr.], $I$, $alpha_2$, $tan alpha_2$, $I/(tan alpha_2)$, $B_l$, $B_H$,
    ),
    ..d3.alpha-2.enumerate().map(((i, x)) => {
      let I = x.I
      let value = x.value
      let B_l = calc.round(x.B_l * 1e6, digits: 4)
      let B_H = calc.round(x.B_H * 1e6, digits: 4)
      (
        $#(i+1)$,
        $#I upright(A)$,
        $#value degree$,
        $#calc.round(x.tan, digits: 5)$,
        $#calc.round(x.Idivtan, digits: 5)$,
        $#B_l dot 10^(-6) space upright(T)$,
        $#B_H dot 10^(-6) space upright(T)$
      )
    }).flatten()
  )
)))

// #align(center, box(width: 70%, figure(
//   table(
//     columns: (auto, auto, auto, auto, auto, auto),
//     align: center,
//     inset: 10pt,
//     table.header(
//       [Nr.], $I$, $alpha_1$, $alpha_2$, $B_l$, $B_H$,
//     ),
//     ..d3.map(x => {
//       let (i, I, alpha_1, alpha_2, B_l, B_H) = x
//       B_l = calc.round(B_l * 1e6, digits: 4)
//       B_H = calc.round(B_H * 1e6, digits: 4)
//       (
//         $#i$,
//         $#I upright(A)$,
//         $#alpha_1 degree$,
//         $#alpha_2 degree$,
//         $#B_l dot 10^(-6)$,
//         $#B_H dot 10^(-6)$
//       )
//     }).flatten()
//   )
// )))

#pagebreak()
#counter(math.equation).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)
#set math.equation(numbering: "(1)")

= Përcaktimi i treguesit të thyerjes së lëngjeve me anën e refraktometrit Abbe

== Teoria e punës

Refraktometri Abbe ëhstë një aparat që shërben për përcaktimin e shpejtë të treguesit të thyerjes së lëngjeve dhe trupave të ngurtë, me saktësi $plus.minus 2 dot 10^(-4)$. Këta tregues ndodhen në intervalin $1.3 space dash.em 1.7$. Ai shërben edhe për matjen e dispersionit mesatar të këtyre lëndëve. Quajmë tregues të thyerjes së një lënde raportin e shpejtësisë së dritës në boshllëk me shpejtësinë e dritës në lëndën e dhënë.
$
  n = c/v
$

Parimi i metodës është i bazuar në dukurinë e pasqyrimit të plotë të brendshëm të dritës kur ajo kalon nga një mjedis optikisht më i dendur në një mjedis tjetër optikisht më pak të dendur.

Marrim dy mjedise të ndarë nga një sipërfaqe e rrafshët AA'. Le të bjerë mbi sipërfaqen ndarëse një rreze drite çfarëdo që formon këndin $i_1$ me normalen e sipërfaqes NN'. Sipas ligjit të thyerjes:
$
  n_1 sin i_1 = n_2 sin r_1
$

Ku $n_1$ dhe $n_2$ janë treguesit e thyerjes ndërsa $i_1$ dhe $r_1$ janë përkatësisht këndet e rënies dhe të thyerjes së rrezes. 

== Përshkrimi i aparatit dhe matjet

Pjesa kryesore e refraktometrit përbëhet prej dy prizmash kënddrejtë prej qelqi, prej prizmint $P_1$ (ndihmës) dhe prizmit $P_2$, me anën e të cilit bëhet matja. Të dy prizmat janë prej materiali qelqi flint, me tregues theyerjeje $1.7$. Ata janë vendosur përballë njëri-tjetrit sipas hipotenuzave, në mënyrë që midis tyre të ketë një hapësirë të vogël me gjerësi rreth $0.1 "mm"$, ku hedhim lëngun që duam të studiojmë. Faqja MN e prizmit $P_1$ është sipërfaqe mate (disi e ashpër). Si rezultat, rrezet e dritës bien në prizmin $P_2$ (në faqen e hipotenuzës KL të tij) nën kënde që ndryshojnë nga $0 degree$ në $90 degree$. Këndet e thyerjes së rrezeve që thyhen nga prizmi $P_2$ (faqja KL) do të ndryshojnë nga $0 degree$ deri në një kënd $r_"max" < 90 degree$, meqënëse lëngu ka tregus thyerjeje më të vogël se prizmi. Rrezja, këndi i rënies së cilës (në faqen KL) është $90 degree$ (rrezja rrëshqitëse), duke u kthyer në kufirin lëng-qelq kalon në prizmin $P_2$ nën këndin kufi (maksimal) të thyerjes $r_1$. Sipas ligjit të thyerjes së dritës, për rrezen rrëshqitëse BC që futet në faqen KL shkruajmë:
$
  n_1 sin i_1 = n_2 sin r_1
$ <refraction-relation-1>

ku
- $n_1$: treguesi i thyerjes i lëngut në studim
- $n_2$: treguesi i thyerjes së prizmit
- $i_1 = 90 degree$: këndi i rënies së rrezes BC
- $r_1$: këndi i thyerjes së rrezes CD në prizmin $P_1$

Për rrezen CD që thyhet në faqen KE shkruajmë:
$
  n_2 sin r_2 = sin i_2
$ <refraction-relation-2>

ku
- $r_2$: këndi i rënies në faqen KE
- $i_2$: këndi i thyerjes së rrezes që del nga prizmi $P_2$
Këtu treguesi i thyerjes së ajrit është marrë $1$.

Rrezja DF përfaqëson kufirin e përhapjes së dritës që kalon në prizëm në faqen KE. Në rrugën e rrezeve që dalin nga kjo faqe vendosim okularin në mënyrë të tillë që rrezja DF të kalojë nëpër mesin e fushës së pamjes së okularit. Atëherë gjysma e fushës së pamjes duket e ndriçuar, kurse pjesa tjetër mbetet e errët. Pra, pozicioni i kufirit të ndarjes së dritës dhe të errësirës në okular, përcaktohet nga këndi kufi i thyerjes së rrezes që del nga faqja KL. Madhësia e këndit kufi $i_k$ të daljes së rrezes (në rastin tonë, $i_k = i_2$) si rrjedhim edhe pozicioni i kufirit dritë-errësirë, varet nga madhësia e treguesit të thyerjest $n_1$, të lëngut në studim.

Duket se këndi $alpha$ i prizmit është i barabartë me $r_1 + r_2$ pra:
$
  alpha = r_1 + r_2
$ <angle-sum-relation>

Duke zëvendësuar në @refraction-relation-1 $i_1 approx 90 degree$ si dhe duke patur parasysh formulat @refraction-relation-2 dhe @angle-sum-relation nxjerrim:
$
  n_1 = sin alpha sqrt(n_2^2 - sin^2 i_k) - cos alpha dot sin i_k
$

Madhësitë $alpha$ dhe $n_2$ janë të njohura, pra del që $n_1$ varet vetëm nga $i_k$. Për të përcaktuar saktë gjysmën e fushës së pamjes së okularit vendosen në të dy fije të kryqëzuara, që priten në mesin e fushës së pamjes.

$S$ është burimi i dritës, $P$ është pasqyra, $P_1$ dhe $P_2$ janë prizmat e përshkruar më sipër, $K_1$ dhe $K_2$ janë kompensatorët që shërbejnë për të zhdukur dispersionin e dritës.

Teoria e refraktometrit që përshkruam më sipër është e vertetë kur përdorim dritë monokromatike. Kur përdoret dritë e bardhe, rrezet me gjatësi vale të ndryshme thyhen nga prizmat nën kënde të ndryshme, kështu që pjesa e ndriçuar e fushës së pamjes nga ajo e errët ndahet me një brez të ngjyrosur me ngjryra të ndryshme. Pikërisht për të eliminuar këtë efekt përdoren kompesatorët $K_1$ dhe $K_2$. Ndërsa $T_1$ dhe $T_2$ janë thjerrëza që përbëjnë tubin e shikimit, në planin vatror të të cilave vendoset retikoli (dy fijet e kryqëzuara).

== Pjesa eksperimentale

Përgatitim 4-6 solucione prej sheqeri me përqëndrime $2%, 4%, 6%, 8%, 10%$ dhe përcaktojmë treguesin e thyerjes për secilin prej tyre në temperaturën e dhomës. Pastaj marrim një solucion sheqeri me përqëndrim të panjohur dhe përcaktojmë treguesin e thyerjes së tij. Ndërtojmë grafikun e varësisë së treguesit të thyerjes nga përqëndrimi. Nga grafiku gjejmë përqëndrimin e solucionit të panjohur.

#figure(
  image("./exercise-results/exercise-21/plot-1.jpg", width: 80%),
)

#let d4 = json("exercise-results/exercise-21/data.json")

$
  a &= (sum (C - overline(C)) (n - overline(n))) / (sum (C - overline(C))^2) \
  a &= #calc.round(d4.a, digits: 6) \ \
  b &= overline(n) - a overline(C) \
  b &= #calc.round(d4.b, digits: 6)
$

$
  n &= a C + b \
  C_x &= (n_x - b) / a \
  C_x &= #calc.round(d4.C_x, digits: 3) %
$
