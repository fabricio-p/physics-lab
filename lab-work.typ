#import "@preview/wrap-it:0.1.0": wrap-content

#let e = "ë"
#let c = "ç"

#let vec-arrow(a) = $scripts(limits(#a)^->)$
#let index-of(el, kind: none) = {
  if kind == none {
    kind = el.func()
  }
  numbering(el.numbering, ..counter(kind).at(el.location()))
}
#let ref-link(el, prefix: "", kind: none) = link(el.location(), prefix + index-of(el, kind: kind))

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
      el.body.text.split(".").at(0)
    )
  } else {
    it
  }
}
#show figure.caption: it => {
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
      LËNDA: FIZIKË 1
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
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(2)

= Studimi i l#(e)vizjes s#(e) nxituar (n#(e) rrafshin e pjerr#(e)t)

== Teoria e pun#(e)s 

L#(e)vizja me nxitim e nj#(e) trupi karakterizohet nga ndryshimi i shpejt#(e)si#(e) n#(e) lidhje me koh#(e)n. Vet#(e) nxitimi p#(e)rcaktohet si raporti i ndryshimit t#(e) shpejt#(e)sis#(e) $Delta limits(v)^->$ me intervalin e koh#(e)s $Delta t$ gjat#(e) t#(e) cilit ndodh ky ndryshim, pra:
$
 #vec-arrow[a]_m = (Delta limits(v)^->) / (Delta t)
$ <acc-derivative-eq>
Indeksi $m$ tek $scripts(limits(a)^->)_m$ n#(e)nkupton nxitimin mesatar. Teorikisht, duke kaluar n limit raportin e mësipërm kur $Delta t -> 0$, merret i ashtuquajturi nxitimi i çastit $limits(a)^->$:
$
  limits(a)^-> = lim_(Delta t -> 0) (Delta limits(v)^->) / (Delta t) = (d limits(v)^->) / (d t)
$

#figure(
  image("./exercise-results/exercise-1/diagram-1.png", width: 60%),
  caption: [
    Një sferë uniforme që rrokulliset pa rrëshqitje përgjatë një plani të pjerrët.
  ]
) <diag-1>

Në këtë punë laboratori, lëvizja me nxitim e trupit përftohet nga lëvizja  e tij në një plan të pjerrët. Në qoftë se do të studiojmë nga pikëpamja dinamike lëvizja e trupit do të konstatojmë se tek ai ushtrohen këto forca: forca gravitacionale $#vec-arrow[F]_g$, forca e kundërveprimit të planit (forca normale) $#vec-arrow[F]_N$ dhe forca e fërkimit $#vec-arrow[f]_s$ e kundërt me drejtimin e lëvizjes (@diag-1). Rezultantja $#vec-arrow[R]$ e këtyre forcave do të shkaktojë nxitimin $#vec-arrow[a]$ të trupit (në përputhje me ligjin e #numbering("I", 2) të Njutonit të zbatuar për këtë rast), pra:
$
  #vec-arrow[a] = #vec-arrow[R] / m
$ <acc-eq>
ku
$
  #vec-arrow[R] = #vec-arrow[F]_g + #vec-arrow[F]_N + #vec-arrow[f]_s
$

Nga barazimi @acc-eq del se nxitimi $a$ është konstant dhe pozitiv, pra kemi një lëvizje të përshpejtuar.
Për të qenë më të saktë duhet thënë se barazimi @acc-derivative-eq zbatohet për rastin e një trupi që rrëshqet në planin e pjerrët. Në rastin tonë trupi (që është një sferë) rrokulliset në planin e pjerrët dhe dinamika e tij ndryshon nga rasti kur ai rrëshqet. Një studim i saktë i dinamikës së rrokullisjes së kësaj sfere në planin e pjerrët ka si konkluzion faktin se lëvizja e qendrës së masës së sferës bëhet me nxitim konstant $a$, pozitiv. Llograritjet nga ana dinamike tregojnë gjithashtu se nxitimi $a$ (kur nuk merret parasysh forca e fërkimit) varet nga këndi $theta$ sipas barazimit $a = g sin theta$. Meqënëse lëvizjen e sferës do ta shqyrtojmë nga pikëpamja kinematike, duhet to kemi parasysh dy formulat kryesore të cilat shprehin rrugën $S$ dhe shpejtësinë $v$ në lëvizjen me nxitim konstant $a$:
$
  S &= v_0 t + (a t^2) / 2 \
  v &= v_0 + a t
$

Meqënëse në eksperimentet tona trupi (sfera) do të lëshohet pa shpejtësi fillestare, formulat e mësipërme do të shkruhen:

$
  S &= (a t^2) / 2 \
  v &= a t
$ <base-formulas>

Formulat @base-formulas janë formula bazë në këtë punë laboratori.

== Pjesa eksperimentale

=== Përshkrimi i shkurtër i pajisjes
Në planin e pjerrët me gjatësi të shfrytëzueshme 80 cm do të lëvizë me nxitim konstant $a$ (pozitiv) një sferë çeliku. Shkallëzimet për çdo 0.1 m në planin e pjerrët na lejojnë të përcaktojmë me saktësi rrugët që do të përshkojë sfera në këtë plan. Lëshimi i sferës nga pika të ndryshme të planit do të bëhet pa shpejtësi fillestare. Me një kronometër elektronik (që mat me saktësi deri në 0.01 s) do të matet koha e lëvizjes së sferës gjatë rrugëve (gjatësive) të ndryshme në planin e pjerrët.

== Ushtrimi 1. Studimi i varësisë së rrugës nga koha. LLogaritja e nxitimit.
Lëshojmë sferën nga pikat me shënimet 0.8 m; 0.7 m; 0.6 m; 0.5 m; në planin e pjerrët. Këto do të jenë vlerat a rrugës $S$ që do të përshkojë sfera. Për secilën rrugë $S$ matim me kronometër 4 herë kohën $t$ që i duhet sferës për të përshkuar rrugën e zgjedhur. Në fletë-matjen që i bashkëngjitet kësaj pune laboratori shënohen rrugët $S$ dhe seritë e matjeve për kohën $t$ që i korrespondon çdo rruge. Duke u nisur nga formula @base-formulas, nxjerrim formulën për llogaritjen e nxitimit $a$:
$
  a = (2S) / t^2
$ <acc-dist-time-formula>

Për llogaritjen e $a$ (për çdo rrugë $S$) me anë të formulës @acc-dist-time-formula, përdoret $overline(t)$.

#let acc-table(delta_xs, avg_ts, acs, acc-name: $a$, caption: none) = align(center,
  box(width: 70%,
    figure(
      table(
        columns: (1fr, ..delta_xs.map(_ => 1fr)),
        inset: 10pt,
        table.header(
          $S$, ..delta_xs.map(delta_x => $#calc.round(delta_x, digits: 2) "m"$)
        ),
        $overline(t)$, ..avg_ts.map(avg_t => $#calc.round(avg_t, digits: 2)$),
        acc-name,
        ..acs.map(a => $#calc.round(a, digits: 2)$)
      ),
      caption: caption
    )
  )
)

#let data1 = json("exercise-results/exercise-1/data.json")

#acc-table(
  data1.delta-xs,
  data1.avg-tss.at(0),
  data1.ass.at(0),
  acc-name: $a_1$,
  caption: ""
)

#let math-block-average(xs, precision: 2) = {
  let content = xs
    .slice(1, none)
    .fold($#calc.round(xs.at(0), digits: precision)$, (cont, a) => {
      $#cont + #calc.round(a, digits: precision)$
    })
  $#content / #xs.len()$
}
#let math-block-abs-error(xs, avg-xs, precision: 2) = {
  let content = xs
    .slice(1, none)
    .fold($|#avg-xs - #calc.round(xs.at(0), digits: precision)|$, (cont, a) => {
      $#cont + |#avg-xs - #calc.round(a, digits: precision)|$
    })
  $#content / #xs.len()$
}

#box(stroke: 1pt + black, inset: 10pt)[$
  overline(a_1) &= #math-block-average(data1.ass.at(0)) \
  overline(a_1) &= #calc.round(data1.avg-as.at(0), digits: 2) \
$]

=== Gabimi absolut dhe relativ
$
  Delta a_1 &= #math-block-abs-error(data1.ass.at(0), calc.round(data1.avg-as.at(0), digits: 2)) \
  Delta a_1 &= #calc.round(data1.as-abs-err.at(0), digits: 2) \
  \
  epsilon_(a_1) &= (Delta a_1) / overline(a_1) \
  epsilon_(a_1) &= #calc.round(data1.as-rel-err.at(0), digits: 2) \
  epsilon_(a_1) &= #(calc.round(data1.as-rel-err.at(0), digits: 2) * 100)%
$

#figure(
  image("./exercise-results/exercise-1/plot-1.jpg", width: 90%),
  caption: [
    Grafiku i matjeve në tabelën e parë
  ]
)

#acc-table(
  data1.delta-xs,
  data1.avg-tss.at(1),
  data1.ass.at(1),
  acc-name: $a_2$,
  caption: ""
)

#box(stroke: 1pt + black, inset: 10pt)[$
  overline(a_2) &= #math-block-average(data1.ass.at(1)) \
  overline(a_2) &= #calc.round(data1.avg-as.at(1), digits: 2)
$]


=== Gabimi absolut dhe relativ
$
  Delta a_1 &= #math-block-abs-error(data1.ass.at(1), calc.round(data1.avg-as.at(1), digits: 2)) \
  Delta a_1 &= #calc.round(data1.as-abs-err.at(1), digits: 2) \
  \
  epsilon_(a_2) & = (Delta a_2) / overline(a_2) \
  epsilon_(a_2) & = #calc.round(data1.as-rel-err.at(1), digits: 2) \
  epsilon_(a_2) & = #(calc.round(data1.as-rel-err.at(1), digits: 2) * 100)%
$

#figure(
  image("./exercise-results/exercise-1/plot-2.jpg", width: 90%),
  caption: [
    Grafiku i matjeve në tabelën e dytë
  ]
)

#box(inset: (top: 20pt))[$
  #text(size: 20pt)[$therefore overline(a_2) > overline(a_1)$]
$]

== Ushtrimi 2. Llogaritja e shpejtësive të sferës në fund të planit të pjerrët

#let vel-table(
  delta_xs,
  avg_ts,
  vs-1,
  vs-2,
  v1-name: $v_1$,
  v2-name: $v_2$,
  caption: none
) = align(center,
  box(width: 70%,
    figure(
      table(
        columns: (1fr, ..delta_xs.map(_ => 1fr)),
        inset: 10pt,
        table.header(
          $S$, ..delta_xs.map(delta_x => $#calc.round(delta_x, digits: 2) "m"$)
        ),
        $overline(t)$, ..avg_ts.map(avg_t => $#calc.round(avg_t, digits: 2)$),
        v1-name,
        ..vs-1.map(v => $#calc.round(v, digits: 2)$),
        v2-name,
        ..vs-2.map(v => $#calc.round(v, digits: 2)$)
      ),
      caption: caption
    )
  )
)

$
  overline(v) = overline(a) t
$

#vel-table(
  data1.delta-xs,
  data1.avg-tss.at(0),
  data1.vss.at(0),
  data1.vss.at(1),
  v1-name: $overline(v_1)$,
  v2-name: $overline(v_2)$,
  caption: ""
)

#figure(
  image("./exercise-results/exercise-1/plot-3.jpg", width: 85%),
  caption: [
    Grafiku i varësië së $v$ nga $t$ për tabelën e parë të matjeve
  ]
)

#figure(
  image("./exercise-results/exercise-1/plot-4.jpg", width: 85%),
  caption: [
    Grafiku i varësië së $v$ nga $t$ për tabelën e dytë të matjeve
  ]
)

#pagebreak()
#counter(math.equation).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

= Studimi i lëkundjeve të lavjerrësit matematik

== Teoria e punës
*Lavjerrësi matematik* ose i thjeshtë realizohet nga një objekt i vogël, i varur në një fije të hollë (jo elastike), të fiksuar, që mund të lëkundet rreth pozicionit të ekuilibrit. Si objekt mund të shërbejë një sferë me rreë shumë të vogël se gjatësia e fijes, ose një trup çfarëdo me dimensione gjithashtu shumë të vogla se gjatësia e fijes.

Po ta zhvendosim pak sferën (trupin) nga pozicioni i ekuilibrit, ajo do të fillojë të lëkundet. Në figurën @pendulum-diagram paraqitet sfera në një çast çfarëdo $t$, dhe që është e zhvendosur me $x$ nga pozicioni i ekuilibrit. Shqyrtojmë forcat që ushtrohen tek sfera. Ato janë:
- forca e rëndesës $#vec-arrow[G] = m #vec-arrow[g]$
- tensioni i fijes $#vec-arrow[T]$

#wrap-content(box[#figure(
  image("./exercise-results/exercise-2/diagram-1.png", width: 60%),
  caption: [
    Diagrami i lavjerrësit matematik
  ]
) <pendulum-diagram>], align: top + left)[
  Forca $#vec-arrow[G]$ është zbërthyer në dy përbërëse, $#vec-arrow[G]_x$ dhe $#vec-arrow[G]_y$. Kjo e fundit ekuilibrohet ndërsa $#vec-arrow[G]_x$ është forca që detyron sferën të kryejë lëvizje lëkundëse. Duke zbatuar ligjin e II të Njutonit për sferën kemi:
  $
    #vec-arrow[G]_x &= m #vec-arrow[a] \
    G_x &= -G sin phi
  $ <pendulum-force>
  Shenja ($-$) tek barazimi @pendulum-force lidhet me fakitin se për kënde $phi$ pozitivë dhe $x$ pozitiv (siç është rasti i figurës), $#vec-arrow[G]_x$ ka kah të kundërt dhe anasjelltas. Pra këndet $phi$ në të djathtë të vertikales konsiderohen pozitivë; gjithashtu dhe zhvendosjet $x$ në të djathtë të pikës së ekuilibrit merren pozitivë.

  Meqënëse në këtë punë laboratori studiohen lëkundjet e lavjerrësit për kënde t\te vegjël, atëherë:
  $
    sin phi approx phi
  $
]
Gjithashtu
$
  phi approx x / l
$
Prandaj:
$
  G_x = -G sin phi approx -G phi approx -m g x/l
$
Duke zëvendësuar tek @pendulum-force marrim:
$
  -m g x/l = m a
$
meqë $a = x''$ kemi:
$
  x'' + g/l x = 0
$
Duke shënuar $g slash l = omega_o^2$ marrim:
$
  x'' + omega_o^2 x = 0
$ <acc-angular-vel-rel>
Ekuacioni @acc-angular-vel-rel është një ekuacion diferencial i rendit të dytë për $x$-in që varet nga koha. Zgjidhja e tij na jep mundësinë të njohim funksionin $x = f(t)$. Pikërisht kjo zgjidhje do të jetë e formës:
$
  x = A cos(omega_o t + alpha)
$ <harmonic-pendulum-function>
Duke iu referuar funksionit @harmonic-pendulum-function, thuhet se sfera kryen lëkundje harmonike.
- $A$: amplituda e lëkundjeve
- $alpha$: faza fillestare
- $omega_o = 2 pi f$: frekuenca ciklike
- $f$: frekuencë e lëkundjeve
Meqënëse $f = 1 slash T$ atëherë:
$
  T = (2pi) / omega_o
$
Duke paturn parasysh që $omega_o^2 = g slash l$, gjejmë për periodën $T$ shprehjen:
$
  T = 2pi sqrt(l / g)
$ <pendulum-period-from-len>
Perioda mund të rritet me zgjatjen e $l$, por masa e sferës nuk ndikon. Perioda $T$, nga ana tjetër, ndikohet nga pozicioni i lavjerrësit në raport me Tokën. Për shkak se forca e fushës gravitacionale të Tokës nuk ësthë e njëtrajtshme kudo, një lavjerrës i caktuar lëkundet më shpejt, dhe kështu ka një periodë më të shkurtër, në lartësi të ulëta dhe në polet e Tokës sesa në lartësi të mëdha dhe në Ekuator.

== Ushtrimi 1. Studimi i varësisë së periodës së lëkundjeve nga gjatësia e lavjerrësit
Gjatësia e lavjerrësit me të cilin do të kryhen matjet, mund të ndryshohet lehtë. Vendoset një gjatësi e caktuar e lavjerrësit (minimale), e cila matet me saktësi me anë të vizores. Gjatësia matet nga pika e varjes deri në qendër të sferës. Zhvendoset sfera me një kënd të vogël dhe lihet e lirë të lëkundet. Matet me kronometër koha $t$ për të cilën lavjerrësi kryen $n = 10$ lëkundje.

Për një gjatësi të caktuar të lavjerrësit kryhet një seri prej 4 matjesh për kohën $t$, seri e cila shënohet në fletë-matje. Rritet gjatësia e lavjerrësit dhe kryhet një seri tjetër matjesh për kohën $t$. E kështu me radhë derisa kemi matje për $6$ gjatësi të ndryshme të lavjerrësit.

Për të gjetur periodën $T$ të lëkundjeve, duhet pjesëtuar koha $t$ (mesatare) me numrin $n$ të lëkundjeve:
$
  T = t/n
$
#let data2 = json("exercise-results/exercise-2/data.json")

#align(center,
  box(width: 75%,
    figure(
      table(
        rows: 2,
        columns: data2.avg-ts.len() + 1,
        inset: 10pt,
        $l$, ..data2.ls.map(l => $#calc.round(l, digits: 2) upright(m)$),
        $overline(t)$, ..data2.avg-ts.map(avg-t => $#calc.round(avg-t, digits: 2) upright(s)$),
        $T$, ..data2.Ts.map(T => $#calc.round(T, digits: 3) upright(s)$),
      ),
    )
  )
)

#figure(
  image("exercise-results/exercise-2/plot-1.jpg", width: 90%),
  caption: [Varësia e periodës nga gjatësia e lavjerrësit]
)

== Ushtrimi 2. Përcaktimi i rënies së lirë $g$

Për të llogaritur nxitimin e rënies së lirë $g$ do të shfrytëzojmë formulën @pendulum-period-from-len. Nga kjo formulë nxjerrim:
$
  g = (4 pi^2 l) / T^2
$ <free-fall-acc-from-period>
Me të dhënat e tabelës 1 (për $l$ dhe $T$) llogaritet g duke përdorur formulën @free-fall-acc-from-period.

#align(center,
  box(width: 75%,
    figure(
      table(
        rows: 2,
        columns: data2.avg-ts.len() + 1,
        inset: 10pt,
        $l space (upright("m"))$, ..data2.ls.map(l => $#calc.round(l, digits: 2)$),
        $g space (upright(m)upright(s)^2)$, ..data2.gs.map(g => $#calc.round(g, digits: 3)$),
      ),
    )
  )
)

Është e qartë se $g$ nuk do të varet nga $l$. Nga tabela nxjerrim mesataren e $g$.
$
  overline(g) &= #math-block-average(data2.gs, precision: 3) \
  overline(g) &= #calc.round(data2.avg-g, digits: 3)
$

Duke iu referuar vlerave gjejmë gabimin absolut dhe relativ $epsilon$ për nxitimin $g$.
#let abs-err-expr = {
  let rows = ()
  let current-row = ()
  for (i, g) in data2.gs.enumerate() {
    let (x, y) = (calc.rem(i, 2), calc.quo(i, 2))
    current-row.push($|#calc.round(data2.avg-g, digits: 3) - #calc.round(g, digits: 3)|$)
    if x != 0 {
      current-row.push($+$)
    }
    if x == 1 {
      rows.push(current-row)
      current-row = ()
    }
  }
  math.mat(delim: none, ..rows)
};
$
  Delta g &= #abs-err-expr / #data2.gs.len() \
  Delta g &= #calc.round(data2.abs-err-g, digits: 3) upright(m) slash upright(s)^2
$
$
  epsilon_g &= (Delta g) / overline(g) \
  epsilon_g &= #calc.round(data2.rel-err-g, digits: 3)%
$

#pagebreak()
#counter(math.equation).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

= Ligji i ruajtjes së energjisë mekanike (rrota e Maksuellit)

== Teoria e punës
Në një sistem të mbyllur energjia mekanike e sistemit mbetet e pandryshuar. Ky pohim përbën ligjin e ruatjes së energjisë mekanike. Në këtë punë laboratori, duke u mbështetur në këtë ligj, studiohet shndërrimi i energjisë potenciale në energji kinetike të lëvizjes tejbartëse dhe të rrotullimit gjatë rënies pa fërkim të rrotës së Maksuellit në fushën e tërheqjes së Tokës. Rrota e Maksuellit ka masë $m$ dhe moment inercie $I_z$ në lidhje me boshtin e rrotullimit. Gjatë rënies nga një lartësi e çfarëdoshme $h$, ajo zotëron energji mekanike të përbërë nga energjia potenciale $E_p$, energjia kinetike e lëvizjes tejbartëse $E_(k t)$ dhe ajo rrotulluese $E_(k "rr")$:
$
  E_M &= E_p + E_(k t) + E_(k"rr") \
  E_M &= m g h + (m v^2) / 2 + (I_z omega^2) / 2
$ <mech-ener-rel>
ku:
- $omega$: është shpejtësia këndore e çastit e qendresës së masës së rrotës
- $v$: shpejtësia lineare e çastit e qendrës së masës së rrotës
- $g$: nxitimi i rënies së lirë
- $h$: lartësia e qendrës së diskut nga një nivel origjine

#figure(
  image("./exercise-results/exercise-4/diagram-1.png", width: 30%),
  caption: [Lidhja midis ndryshimit elementar të këndit $dif phi$ dhe ndryshimit elementar të lartësisë $dif h$ në rrotën e Maksuellit]
) <maxwell-wheel-diag>

Në qoftë se shënojmë me $r$ rrezen e boshtit të rrotës së Maksuellit, siç duket nga @maxwell-wheel-diag  do të kemi:
$
  dif h &= r dif phi \
  v = (dif h) / (dif t) &= (dif phi) / (dif t) r = omega dot.op r
$ <vel-ang-vel-rel>
Si origjinë të matjes së lartësive do të marrim pikën $O$ kur rrota e Maksuellit ndodhet në pozicionin e sipërm të saj ($v = 0, E_(k t) = 0, omega = 0, E_(k"rr") = 0$).

Meqënëse gjatë rënies së rrotës kjo lartësi vjen duke u zvogëluar, në llogaritjet e mëposhtme ajo është konsideruar negative. Si rrjedhim kemi:
$
  0 &= -m g h + (m v^2) / 2 + (I_z omega^2) / 2 \
  m g h &= (m v^2) / 2 + (I_z omega^2) / 2
$ <0-mech-ener-rel>
Duke kombinuar relacionet @vel-ang-vel-rel dhe @0-mech-ener-rel marrim:
$
  m g h &= (m v^2) / 2 + (I_z v^2) / (2 r^2) \
  2r^2 m g h &= m v^2 r^2 + I_z v^2 \
  (2r^2 m g h) / v^2 &= m r^2 + I_z \
  I_z &= (2r^2 m g h) / v^2 - m r^2 \
  I_z &= m r^2 ((2g h) / v^2 - 1)
$ <momentum-of-inertia>
ku $m$ është masa e rrotës dhe $r$ rrezja e boshtit të saj. Në trajtë të përgjithshme, duke kombinuar relacionet @mech-ener-rel dhe @vel-ang-vel-rel marrim, dhe meqënëse energjia mekanike mbetet e pandryshuar, derivati i saj me kohën jep:
$
  (dif E_M) / (dif t) = 0 = -m g v + 1/2 (m + I_z / r^2) v (dif v) / (dif t)
$ <mech-ener-derive>
Nga kjo ne arrijmë në përfundimin se:
$
  m g v &= 1/2 (m + I_z / r^2) v (dif v) / (dif t) \
  m g &= 1/2 (m + I_z / r^2) (dif v) / (dif t) \
  a = (dif v) / (dif t) &= (2m g) / (m + I_z slash r^2)
$ <maxwell-wheel-acceleration-formula>
është nxitimi i lëvizjes tejbartëse të qëndresës së masës së rrotës së Maksuellit. Me anë të së cilës nxjerrim rezultatet e mëposhtme:
$
  dif v &= (2m g) / (m + I_z slash r^2) dif t \
  v(t) &= ((2m g) / (m + I_z slash r^2)) t
$ <velocity-function>
$
  (dif h) / (dif t) &= ((2m g) / (m + I_z slash r^2)) t \
  dif h &= ((2m g) / (m + I_z slash r^2)) t dif t \
  h(t) &= ((m g) / (m + I_z slash r^2)) t^2
$ <height-function>

== Të dhëna
#math.equation[$
  m &= 0.514 "kg" \
  r &= 2.5 * 10^(-3) upright(m)
$]

== Ushtrimi 1. Llogaritja e shpejtësisë të lëvizjes tejbartëse të rrotës <4-ex-1>
Duke marrë lartësi të ndryshme $h$, pa e ndryshuar pozicionin e fotocelulës në suport, matet koha e plotë $t$ e rënies së rrotës. Për çdo lartësi matja e kohës bëhet disa herë dhe gjendet vlera mesatare. Pas kësaj, njehsohet shpejtësia duke matur kohën $t_0$ që i duhet boshtit të rrotës, me diametër $2r$ të kalojë para fotocelulës. Si rrjedhim shpejtësia do të gjendet nga:
$
  v = (2r)/t_0
$

== Ushtrimi 2. Përcaktimi i nxitimit të lëvizjes tejbartëse të rrotës
Me të dhënat e tabelës së parë, ndërtohen grafikët e varësisë së lartësisë dhe shpejtësisë nga koha. Sipas formulës @height-function funksioni $h(t) ~ t^2$ (paraqet një funksion parabolik) dhe sipas formulës @velocity-function funksioni $v(t) ~ t$ (paraqet një funksion linear).
Më tej përcaktohet nxitimi i lëvizjes tejbartëse të rrotës duke përdorur metodën e regresit linear për varësinë $v = f(t) = a t$ e cila siç e dimë paraqet një drejtëz.
Nga ana tjetër, të llogaritet vlera e nxitimit të lëvizjes tejbartëse të duke u nisur direkt nga formula @maxwell-wheel-acceleration-formula. Sipas kësaj formule mjafton të njohim masën $m$, momentin e inercisë $I_z$ si dhe rrezen e rrotës $r$.

#let data4 = json("exercise-results/exercise-4/data.json")

$
  overline(t) &= (sum t) / 4 \
  overline(t) &= #calc.round(data4.avg-t, digits: 4) \ \

  overline(v) &= (sum v) / 4 \
  overline(v) &= #calc.round(data4.avg-v, digits: 4)
$
$
  a &= (sum (t - overline(t)) (v - overline(v))) / (sum (t - overline(t))^2) \
  a &= #calc.round(data4.reg-a, digits: 5) \ \

  b &= overline(v) - a overline(t) \
  b &= #calc.round(data4.reg-v0, digits: 5) \
$

$
  overline(a) &= 1/4 sum m r^2 ((2g h) / v^2 - 1) \
  overline(a) &= #calc.round(data4.avg-a, digits: 5) upright(m) slash upright(s)^2
$

#box(inset: (top: 20pt))[$
  #text(size: 20pt)[$therefore overline(a) approx a$]
$]

#figure(
  image("./exercise-results/exercise-4/plot-1.jpg", width: 100%),
  caption: [Varësia e lartësisë dhe shpejtësisë nga koha]
)

== Ushtrimi 3. Përcaktimi i momentit të inercisë së rrotës së Maksuellit <4-ex-3>
Me vlerat  e matura nga @4-ex-1[Ushtrimi 1] për lartësinë $h$ dhe me vlerat përkatëse të kohëve të rënies $t$, nga formula @momentum-of-inertia njehsohet momenti i inercisë së rrotës së Maksuellit $I_z$. Gjithashtu llogaritet dhe vlera mestare e $I_z$
$
  overline(I_z) &= #math-block-average(data4.I_zs, precision: 5) \
  overline(I_z) &= #calc.round(data4.avg-I_z, digits: 5) upright("kg") upright(m)^2
$

== Ushtrimi 4. Vërtetimi i ligjit të ruajtjes së energjisë
Meqënëse gjatë rënies së rrotës së Maksuellit energjia potenciale që ajo ka në lartësinë $h$ shndërrohet në energji kinetike të lëvizjes tejbartëse dhe energji kinetike të lëvizjes rrotulluese, vihet re ligji i ruajtjes së energjisë mekanike:
$
  m g h = (m v^2) / 2 + (I_z v^2) / (2 r^2)
$ <mech-ener-pres-formula>
Duke përdorur për $v$ dhe $I_z$ vlerat e njehsuara në ushtrimet @4-ex-1[1] dhe @4-ex-3[3], në lartësinë përkatëse $h$, vërtetojmë ligjin e ruajtjes së energjisë mekanike duke përdorur formulën @mech-ener-pres-formula. Në këto kushte, vlera e anës së majtë të formulës @mech-ener-pres-formula duhet të jetë pothuajse e barabartë me vlerën e anës së djathtë. Për këtë qëllim plotësohet Tabela 3.

#pagebreak()
#counter(math.equation).update(0)
#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)
#set math.equation(numbering: "(1)")

= Ligji i ruajtjes së impulsit dhe energjisë mekanike. Lavjerrësi balistik

== Pjesa teorike
Goditjet janë një mënyrë e bashkëveprimit të trupave. Gjatë goditjeve, koha e bashkëveprimit është relativisht e vogël në krahasim me kohën e lëvizjes së trupave para e pas bashkëveprimit. Pra, gjatë një goditjeje, gjendja e lëvizjes së trupave ndryshon menjëherë. Shqyrtojmë rastin ku dy sfera metalike me masa $m_1$ dhe $m_2$ lëvizin në drejtim të njëra tjetrës n\ një rrafsh horizontal, me shpejtësi përkatësisht $v_1$ dhe $v_2$. Në një çast ato goditen dhe më pas vazhdojnë të lëvizin me shpejtësi, përkatësisht $u_1$ dhe $u_2$. Matjet e kryera në këtë eksperiment tregojnë që gjatë bashkëveprimit madhësite e mësipërme lidhen në shprehjen nga ligji i ruajtes së impulsit në trajtë:
$
  m_1v_1 + m_2v_2 = m_1u_1 + m_2u_2
$

Madhësia $p = m v$ quhet sasi e lëvizjes së trupit (ose impuls i trupit) me masë $m$ që lëviz me shpejtësi $v$ dhe shprehja e mësipërme përbën atë që quhet ligji i ruajtjes së sasisë së lëvizjes. Ky ligj ka vend në të gjithë sistemet e izoluara, pavarësisht nga lloji i bashkëveprimit midis trupave dhe formulohet kështu: në një sistem të izoluar trupash, sasia e lëvizjes e sistemit para bashkëveprimit është e njëjtë me sasinë e lëvizjes së sistemit pas bashkëveprimit.

Goditjet janë 2 llojesh:
- Goditje elastike. Në këtë rast kemi ruajtje të energjisë kinetike nga njëri trup tek tjetri, pa ndryshuar energjinë e tyre të brendshme. Kështu, edhe energjia kinetike e sistemit para bashkëveprimit është e njëtjë me energjinë kinetike të tij pas bashkëveprimit
- Goditje jo elastike. Në këtë rast energjia kinetike e sistemit nuk ruhet, por një pjesë e saj shndërrohet.

Në këtë punë laboratori do të analizojmë goditjen jo elastike të dy trupave, njëri nga të cilët, para goditjes, është në prehje dhe pas goditjes trupat lëvizin së bashku. Për thjeshtësi, të dy trupat pas goditjes do t'i marrim si një pikë materiale të vendosur në qendrën e masës së tyre, të shënuar ne pajisje.

Një sferë e vogël çeliku me masë $m$ lëviz horizontalisht me shpejtësi $v$, godet kutinë që është në prehje dhe mbetet në të. Pas goditjes, sistemi kuti-sferë vihet në lëvizje dhe fija shmanget me një kënd $alpha$. Duke njohur masat $M$ dhe $m$, largësinë $l$ të qendrës së masës së trupave deri në pikën e varjes dhe këndin $alpha$, mund të përcaktohet shpejtësia e sferës. Për këtë le të zbatojmë ligjin e ruajtjes së lëvizjes për sistemin:
$
  m dot.op v = (m + M) u
$ <impulse-equation>

ku $u$ është shpejtësia e sistemit kuti-sferë, menjëherë pas goditjes.

Në pjesën e dytë të eksperimentit, sistemi kuti-sferze tani lëviz me një shpejtësi fillestare $u$, mbi rrethin me rreze $l$ dhe kalon nga pozicioni $1$ në pozicionin $2$, ku trupat ndalen. Pas goditjes, energjia mekanike e sistemit ruhet (duke neglizhuar fërkimin me ajrin). Zbatojmë ligjin e ruajtes së energjisë mekanike për këto dy pozicione, pra shkruajmë
$
  E_(m 1) = E_(m 2)
$
Zgjedhim si nivel bazë pozicionin $1$. Në këtë pozicion sistemi zotëron vetëm energji kinetike.
Pra:
$
  E_(m 1) = E_(k 1) = 1/2 (m + M)u^2
$ <eq-em-ek-equiv>
Në pozicionin $2$ sistemi ndalon, pra zotëron vetëm energji potenciale:
$
  E_(m 2) = E_(p 2) = (m + M) g dot.op h
$ <eq-em-ep-equiv>

Duke barazuar ekuacionin @eq-em-ek-equiv me @eq-em-ep-equiv merret:
$
  1/2 (m + M)u^2 &= (m + M)g h \
  1/2 u^2 &= g h \
  u &= sqrt(2 g h)
$

Nga gjeometria e figurës shihet se ka vend lidhja:
$
  h &= l - l cos alpha \
    &= l(1 - cos alpha) \
    &= 2l((1 - cos alpha) / 2) \
    &= 2l sin^2 alpha / 2
$

Nga ku përcaktohet shpejtësia $u$ e sistemit pas goditjes:
$
  u &= sqrt(2 g dot.op 2l sin^2 alpha / 2) \
  u &= 2sqrt(g l) sin alpha / 2
$ <after-collision-vel>

Nga ekuacioni @impulse-equation mund të llogarisim shpejtësinë e sferës para goditjes:
$
  v = 2 ((m + M) / m) sqrt(g l) sin alpha / 2
$ <before-collision-vel>

Goditja e sferës është jo elastike, prandaj energjia kinetike e sistemit pas goditjes nuk është e njëjtë me energjinë kinetike të sistemit pas goditjes.
Nga përcaktimi i shpejtësive para dhe pas goditjes mund të llogariten dhe vlerat e energjisë.

Para goditjes, energji kinetike ka vetëm sfera; kutia është në prehje. Pra sistemi ka energjinë kinetike:
$
  E_(k 1) = 1/2 m v^2
$ <before-collision-Ek>
Pas goditjes, energjia kinetike e sistemit përcaktohet:
$
  E_(k 2) = 1/2 (m + M) u^2
$ <after-collision-Ek>
Shpejtësitë $v$ dhe $u$ llogariten nga shprehjet @after-collision-vel dhe @before-collision-vel. Nga raporti i ekuacioneve @after-collision-Ek dhe @before-collision-Ek, pas disa veprimeve të thjeshta, duke përdorur ekuacionin @impulse-equation rrjedh:
$
  E_(k 2) / E_(k 1) = m / (m + M)
$ <after-before-collsion-Ek-ratio>

== Pjesa eksperimentale
Puna e laboratorit ka për qëllim të verifikojë ligjet e ruajtjes së impulsit dhe të energjisë mekanike. Për këtë duhet:
1. të përcaktohet shpejtësia e sferës para godtijes
2. të vlerësohet energjia kinetike fillestare dhe ajo përfundimtare e sistemit.
Pajisja që përdoret quhet *lavjerrës balistik*. Pjesët kryesore të tij janë:
#enum(
  numbering: "a)"
)[një kutizë e vogël me një fole cilindrike ku qëndron sfera pas goditjes. Kutia është e fiksuar në një shufër që mund të rrotullohet rreth një bosthi
][raportor për leximin e këndit $alpha$
][tregues i këndit
][lëshuesi i sferës: një sistem i thjeshtë i përbërë nga një piston i vogël metalik dhe një sustë që e komandon atë. Me anën e këtij lëshuesi, sferës mund t'i komunikohen tri shpejtësi të ndryshme
][shufër metalike për nxjerrjen e sferës nga "foleja"]

== Ushtrimi 1. Përcaktimi i shpejtësisë së sferës
Vendoset sfera tek lëshuesi, i cili fiksohet në pozicionin e parë. Në këtë pozicion sfera merr një shpejtësi $v$. Vendoset treguesi i këndit në pozicion vertikal, pra në $alpha = 0$. Me kujdes lirohet lëshuesi. Matet këndi $alpha$ i shmangjes së treguesit.
Për këtë shpejtësi matjet përsëriten tre herë dhe gjendet vlera mesatare e këndit $alpha$. Me këtë vlerë, duke përdorur formulën @before-collision-vel, njehsohet shpejtësia e sferës. Eksperimenti zhvillohet njësoj dhe për dy pozicionet e tjera të lëshuesit.

#let data7 = json("exercise-results/exercise-7/data.json")

#align(center,
  box(width: 70%,
    figure(
      table(
        rows: 2,
        columns: data7.avg-alphas.len() + 1,
        inset: 10pt,
        $overline(alpha)$, ..data7.avg-alphas.map(alpha => $#calc.round(alpha, digits: 2) degree$),
        $v (upright("m/s"))$, ..data7.vs.map(v => $#calc.round(v, digits: 2)$)
      ),
    )
  )
)
== Ushtrimi 2. Vlerësimi i energjive kinetike
Nga shprehja @before-collision-vel llogaritet $u$. Duke përdorur shprehjet @before-collision-Ek dhe @after-collision-Ek vlerësohen $E_(k 1)$, $E_(k 2)$ dhe raporti $E_(k 2) slash E_(k 1)$.
Përfundimi krahasohet me atë që përftohet duke përdorur shprehjen @after-before-collsion-Ek-ratio.
#let row = (data7.vs, data7.us, data7.E_k1s, data7.E_k2s, data7.E_k-ratio)
#let mass-ratio = calc.round(data7.mass-ratio, digits: 3)
#align(center,
  box(width: 90%,
    figure(
      table(
        columns: (1fr, ..row.map(_ => 1fr), 1.5fr),
        table.header([Nr], $v$, $u$, $E_(k 1)$, $E_(k 2)$, $E_(k 2) slash E_(k 1)$, $m slash (m + M)$),
        $1$, ..row.map(c => $#calc.round(c.at(0), digits: 3)$), $#mass-ratio$,
        $2$, ..row.map(c => $#calc.round(c.at(1), digits: 3)$), $#mass-ratio$,
        $3$, ..row.map(c => $#calc.round(c.at(2), digits: 3)$), $#mass-ratio$,
      )
    )
  )
)
