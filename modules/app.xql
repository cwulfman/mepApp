xquery version "3.1";

module namespace app="http://digitalhumanities.princeton.edu/mep/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://digitalhumanities.princeton.edu/mep/config" at "config.xqm";

import module namespace datetime = "http://exist-db.org/xquery/datetime";
import module namespace functx = "http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";

import module namespace rest = "http://exquery.org/ns/restxq" ;
(:  declare namespace rest="http://exquery.org/ns/restxq"; :)
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";


declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function app:_active-subscriptions($subscriptions, $fromDate, $toDate)
as element()*
{    
    $subscriptions[(@start <= $toDate) and (@end >= $fromDate)]
};

declare function app:sex-distribution($node as node(), $model as map(*))
{
    let $expats := collection($config:data-root)//tei:listPerson[@xml:id = 'expats']
    let $identified-as-female :=
       $expats/tei:person[tei:sex/@value = $config:female-key]
    let $identified-as-male :=
        $expats/tei:person[tei:sex/@value = $config:male-key]
    let $unidentified :=
        $expats/tei:person[empty(tei:sex)]
return
    <table class="table">
        <caption><p>Sex Distribution</p></caption>
        <thead>
            <tr>
                <th>Identified Sex</th>
                <th>Number of Individuals</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Identified as Female</td>
                <td>{ count($identified-as-female) }</td>
            </tr>
            <tr>
                <td>Identified as Male</td>
                <td>{ count($identified-as-male) }</td>
            </tr>
            <tr>
                <td>Unidentified Sex</td>
                <td>{ count($unidentified) }</td>
            </tr>
        </tbody>
    </table>
};

declare function app:national-distribution($node as node(), $model as map(*))
{
    let $expats := collection($config:data-root)//tei:listPerson[@xml:id = 'expats']
    let $nationalities := $expats//tei:nationality
    return
        <table class="table">
            <caption><p>Nationality Distribution</p></caption>
            <thead>
                <tr>
                    <th>Nationality Key</th>
                    <th>Number of instances in database</th>
                </tr>
            </thead>
            <tbody> {
        for $key in distinct-values($nationalities/@key)
        let $label := xs:string($key)
        let $count := count($nationalities[@key=$key])
        order by $count descending
        return
            <tr>
            <td>{ $label }</td>
            <td>{ $count }</td>
            </tr>
            
        }</tbody>
        </table>
    
};

declare %templates:wrap function app:cards($node as node(), $model as map(*))
{
    let $cards := collection($config:data-root)//tei:TEI[tei:teiHeader//tei:classCode='300026802']
    return map { "cards" : $cards }
};

declare %templates:wrap function app:current-card($node as node(), $model as map(*), $subscriber as xs:string?)
{
    let $key  := 
        if ($subscriber) then "#"||$subscriber
        else ""
        
    let $card :=
        if ($key) then
            collection($config:data-root)//tei:TEI[tei:teiHeader//tei:particDesc/tei:person/@ana = $key]
        else ()
    return
        if ($card) then
            map { "current-card" : $card }
        else ()
};

declare %templates:wrap function app:cardholders($node as node(), $model as map(*))
{
    <ul> {
    for $card in $model('cards')
    let $person := $card/tei:teiHeader//tei:particDesc/tei:person[@role = 'cardholder']
    let $label  := xs:string($person[1]/tei:persName)
    let $key    := $person[1]/@ana
    let $key    := fn:replace($key, "^#?(.*)$", "$1")
    let $link   := 'cards.html?subscriber=' || $key
    order by tokenize($label, ' ')[last()]
    return
        <li><a href="{$link}">{ $label }</a></li>
    }</ul>
};

declare function app:view-card($node as node(), $model as map(*))
{
    let $card := $model('current-card')
    let $xsl  := doc($config:app-root || "/resources/xsl/cardview.xsl")

    return 
        if ($card) then
            transform:transform($card, $xsl, ())
        else ()
};

declare function app:view-notebook($node as node(), $model as map(*))
{
    let $notebook := doc($config:data-root || "/transcriptions/notebook.xml")
    let $xsl      := doc($config:app-root || "/resources/xsl/notebookview.xsl")
    
    return transform:transform($notebook, $xsl, ())
};

declare function app:view-logbooks($node as node(), $model as map(*))
{
    let $xsl      := doc($config:app-root || "/resources/xsl/logbookview.xsl")
    let $years    := collection($config:data-root || "/transcriptions/logbooks")//tei:div[@type = 'year']

    return transform:transform($years, $xsl, ())
};


declare %templates:wrap function app:expats($node as node(), $model as map(*))
{
    let $expats := collection($config:data-root)//tei:listPerson[@xml:id='expats']/tei:person
    return map { "expats" : $expats }
};

declare %templates:wrap function app:expats-list($node as node(), $model as map(*))
{
    let $expats := $model('expats')
    return
        <ol id="expats">{
            for $person in $expats
            let $surname  := $person/tei:persName[1]/tei:surname[1]
            let $forename := $person/tei:persName[1]/tei:forename[1]
            let $lifespan := $person/tei:birth || '--' || $person/tei:death
            let $key      := $person/@xml:id
            let $link     := "expats.html?person=" || $key
            order by $surname
            return
                <li><a href="{$link}">
                    { string-join(($forename, $surname), ' ') }
                </a></li>
        }</ol>
};

declare %templates:wrap function app:expat($node as node(), $model as map(*), $person as xs:string?)
{
    let $expat := 
        if ($person) then
            collection($config:data-root)//tei:listPerson[@xml:id='expats']/tei:person[@xml:id = $person]
        else ()
        
        return map { 'current-expat' : $expat }
};

declare %templates:wrap function app:expat-info($node as node(), $model as map(*))
{
    let $expat := $model('current-expat')
    return
        if ($expat) then
        <section>
            <header>
                <h3>{ 
                    let $namestring := $expat/tei:persName/tei:surname[1] || ', ' || $expat/tei:persName/tei:forename[1] 
                    return $namestring
                }</h3>
            </header>
            <dl class="dl-horizontal">
                <dt>viaf</dt>
                <dd>{ 
                    let $viafnum := $expat/tei:idno[@type='viaf']
                    let $link    := 'http://viaf.org/viaf/' || $viafnum
                    return
                    <a href="{$link}">{ $viafnum }</a>                
                }</dd>
                
                <dt>birth</dt>
                <dd>{ $expat/tei:birth }</dd>
                
                <dt>death</dt>
                <dd>{ $expat/tei:death }</dd>
                
                <dt>identified sex</dt>
                <dd>{ 
                    let $sex-key := $expat/tei:sex/@value
                    return
                        if ($sex-key = $config:female-key) then "female"
                        else if ($sex-key = $config:male-key) then "male"
                        else "unestablished"
                }</dd>
                
                <dt>identified nationality</dt>
                <dd><ul class="list-inline">
                    {
                        for $nationality in $expat/tei:nationality
                        return <li>{ xs:string($nationality/@key) }</li>
                    }
                </ul></dd>
                
                <dt>known addresses</dt>
                <dd>{
                    let $residences := $expat/tei:residence
                    return
                        <ul class="list-unstyled">
                        { 
                            for $residence in $residences return <li>{ $residence }</li>
                        }
                        </ul>
                }</dd>
                
                <dt>books on card</dt>
                <dd>{
                        let $key  := 
                            if ($expat) then "#"||$expat/@xml:id
                            else ""
        
                        let $card :=
                            if ($key) then
                            collection($config:data-root)//tei:TEI[tei:teiHeader//tei:particDesc/tei:person/@ana = $key]
                            else ()
                            
                        let $bibls :=
                            if ($card) then
                                $card//tei:bibl
                            else ()
                            
                        let $titles :=
                            for $bibl in $bibls
                            return
                                if ($bibl/tei:title) then 
                                for $title in $bibl/tei:title return xs:string($title)
                                else xs:string($bibl)
                        return
                            
                            <ul>
                                {
                                    for $title in distinct-values($titles)
                                    return <li>{ $title }</li>
                                }
                            </ul>
                            
                }</dd>
            </dl>
        </section>
        else ()
};


declare %templates:wrap function app:logbook-data-table($node as node(), $model as map(*))
{
    <table class='table'>
        <caption><p>Subscriptions</p></caption>
        <thead>
            <tr>
                <th>Year</th>
                <th>Number of Subscriptions</th>
            </tr>
        </thead>
        <tbody>
    {
        for $year in collection($config:data-root || "/transcriptions/logbooks")//tei:div[@type='year']
        let $date := xs:string($year/tei:head/tei:date) 
        let $subcount := count($year//tei:event[@type='subscription'])
        order by $date
        return
         <tr>
             <td>{ $date }</td>
             <td>{ $subcount }</td>
         </tr>
     }
        </tbody>
     </table>

};


declare %templates:wrap function app:subscribers-old($node as node(), $model as map(*))
{
    let $subscribers := collection($config:data-root || "/transcriptions/logbooks")//tei:persName
    return map { "subscribers" : $subscribers }
};


declare %templates:wrap function app:subscribers($node as node(), $model as map(*))
{
    let $subscribers := doc($config:data-root || "/transcriptions/personography.xml")//tei:person
    return map { "subscribers" : $subscribers }
};

declare %templates:wrap function app:subscriber-list($node as node(), $model as map(*))
{
    let $subscribers := $model('subscribers')
    return
        <ul id="subscribers" class="list-group">{
        for $subscriber in $subscribers
        let $sortkey := xs:string($subscriber/tei:persName[1]/tei:surname[1])
        let $label := local:name-to-displayName($subscriber/tei:persName)

        return
         <li><a href="member.html?id={$subscriber/@xml:id}">{$label}</a></li>

      }</ul>
};


declare %templates:wrap function app:subscriber-list-old($node as node(), $model as map(*))
{
    let $subscribers := $model('subscribers')
    return
        <ul id="subscribers" class="list-group">{
            for $nameref in distinct-values($subscribers/@ref)
            let $key := substring-after($nameref, '#')
            let $link  := if ($key) then "subscribers.html?person=" || $key else ()
            let $subrefs := $subscribers[@ref = $nameref]
            let $label := 
                if ($subrefs[1]/text())
                then xs:string($subrefs[1])
                else "[unnamed]"
            order by $key
            return
                <li class="list-group-item">
                    <span class="badge">{count($subrefs)}</span>
                    <span>
                    {
                        if ($link) then <a href="{$link}">{ $label }</a> else $label
                    }
                    </span>
                    
                </li>
      }</ul>
};

declare %templates:wrap function app:subscriber($node as node(), $model as map(*), $person as xs:string?)
{
    let $key :=
        if ($person) then "#"||$person else ()
    
    let $subscriber := 
        if ($key) then
            collection($config:data-root || "/transcriptions/logbooks")//tei:persName[@ref = $key]
        else ()
        
        return map { "current-subscriber" : $subscriber }
};

declare %templates:wrap function app:subscriber-name($node as node(), $model as map(*))
{
    let $subscriber := $model('current-subscriber')
    return
        if ($subscriber) then
            $subscriber[1]/text()
        else ()
};

declare %templates:wrap function app:current-subscriptions($node as node(), $model as map(*))
{
    let $subscriber := $model('current-subscriber')
    let $xsl        := doc($config:app-root || "/resources/xsl/subscriberview.xsl")
    let $events     := collection($config:data-root || "/transcriptions/logbooks")//tei:event[.//tei:persName = $subscriber]
    let $table      :=
        for $event in $events
        let $date      := $event/ancestor::tei:div[@type='day']/tei:head/tei:date,
            $type      := xs:string($event/@type),
            $duration  := $event/tei:p/tei:measure[@type='duration'],
            $frequency := $event/tei:p/tei:measure[@type='frequency'],
            $price     := $event/tei:p/tei:measure[@type='price'],
            $deposit   := $event/tei:p/tei:measure[@type='deposit']            

        order by $date
        return
            <eventrec type="{$type}">
            { $date, $duration, $frequency, $price, $deposit }
            </eventrec>
 
     return transform:transform($table, $xsl, ())

    };
    
declare function app:_calendar-chart-data()
{
    let $days := collection($config:data-root || "/transcriptions/logbooks")//tei:div[@type = 'day']
    return
        <table>
        {
            for $day in $days
            let $events := $day//tei:event
            order by $day/tei:head/tei:date/@when-iso
            return
                <row>
                    <col>{ xs:string($day/tei:head/tei:date/@when-iso) }</col>
                    <col>{ count($events)  }</col>
                </row>
        }
        </table>

};

declare function app:subscription-calendar($node as node(), $model as map(*))
{
let $chart-data := app:_calendar-chart-data()

let $items := 
    for $row in $chart-data/row
    let $date := xs:date($row/col[1])
    let $count := xs:int($row/col[2])
    let $map := map { "day": $date, "num" : $count }
    return
    $map
    
let $array := array { $items }

return
    <script type="text/javascript">
        var CALDATA = {
        serialize($array, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>)
        }
    </script>
};

declare function app:sex-distribution-chart($node as node(), $model as map(*))
{
    let $expats := collection($config:data-root)//tei:listPerson[@xml:id = 'expats']
    let $identified-as-female :=
       $expats/tei:person[tei:sex/@value = $config:female-key]
    let $identified-as-male :=
        $expats/tei:person[tei:sex/@value = $config:male-key]
    let $unidentified :=
        $expats/tei:person[empty(tei:sex)]
        
    let $iaf :=  map { "label": "identified as female", "num": count($identified-as-female) }
    let $iam :=  map { "label": "identified as male", "num": count($identified-as-male) }
    let $uni :=  map { "label": "unidentified", "num": count($unidentified) }
    

    let $array := array { $uni, $iam, $iaf}
    let $array := array:append($array, $uni)  (: Don't know why I need this hack: pie-chart visualization drops first element of the array :)
    return
    <script type="text/javascript">
        var SEXDATA = {
        serialize($array, 
        <output:serialization-parameters>
            <output:method>json</output:method>
        </output:serialization-parameters>)
        }
    </script>  
};

declare function app:nationality-distribution-chart($node as node(), $model as map(*))
{
    let $expats := collection($config:data-root)//tei:listPerson[@xml:id = 'expats']
    let $nationalities := $expats//tei:nationality
    let $items :=
        for $key in distinct-values($nationalities/@key)
        let $label := xs:string($key)
        let $count := count($nationalities[@key=$key])
        let $map := map { "label": $label, "num" : xs:int($count)    }
        return $map
        
    let $array := array { $items }
    let $array := array:append($array, $items[1]) (: Don't know why I need this hack: pie-chart visualization drops first element of the array :)

    return
        <script type="text/javascript">
            var NATDATA = {
            serialize($array, 
         <output:serialization-parameters>
            <output:method>json</output:method>
         </output:serialization-parameters>)
        }
     </script>
};

declare function app:active-subscriptions-chart-old($node as node(), $model as map(*))
{
    let $subscriptions := 
     for $event in collection("/db/mep-data/transcriptions/logbooks")//tei:event[@type='subscription' or @type='renewal']
     let $subDate := xs:date($event/ancestor::tei:div[@type='day'][1]/tei:head[1]/tei:date[1]/@when-iso)
     let $duration :=
      if ($event/tei:measure[@type='duration'])
       then xs:int($event/tei:measure[@type='duration'])
      else 0
     order by $subDate
     return 
      <subscription begin="{$subDate}" end="{functx:add-months($subDate, $duration)}"/>

    let $activeSubscriptions :=
    for $year in collection("/db/mep-data/transcriptions/logbooks")//tei:div[@type='year']
     for $month in $year/tei:div[@type='month']
      let $beginMonth := xs:date($month//tei:div[@type='day'][1]/tei:head/tei:date/@when-iso)
      let $endMonth   := xs:date($month//tei:div[@type='day'][last()]/tei:head/tei:date/@when-iso)
      let $active     := count(app:_active-subscriptions($subscriptions, $beginMonth, $endMonth))
      order by $beginMonth
      return map { "date": $beginMonth, "count": $active  }


    let $array := array { $activeSubscriptions }
    let $array := array:append($array, $activeSubscriptions[1]) (: Don't know why I need this hack: pie-chart visualization drops first element of the array :)

    return
        <script type="text/javascript">
            var ACTIVESUBDATA = {
            serialize($array, 
             <output:serialization-parameters>
              <output:method>json</output:method>
             </output:serialization-parameters>)
            }
        </script>
};

declare function app:active-subscriptions-chart($node as node(), $model as map(*))
{
    let $subscriptions := doc('/db/mep-data/data/subscriptions.xml')//subscription
(:    let $subscriptions := local:subscriptions():)

    let $activeSubscriptions :=
    for $year in collection("/db/mep-data/transcriptions/logbooks")//tei:div[@type='year']
     for $month in $year/tei:div[@type='month']
      let $beginMonth := xs:date($month//tei:div[@type='day'][1]/tei:head/tei:date/@when-iso)
      let $endMonth   := xs:date($month//tei:div[@type='day'][last()]/tei:head/tei:date/@when-iso)
      let $active     := count(app:_active-subscriptions($subscriptions, $beginMonth, $endMonth))
      order by $beginMonth
      return map { "date": $beginMonth, "count": $active  }


    let $array := array { $activeSubscriptions }
    let $array := array:append($array, $activeSubscriptions[1]) (: Don't know why I need this hack: pie-chart visualization drops first element of the array :)

    return
        <script type="text/javascript">
            var ACTIVESUBDATA = {
            serialize($array, 
             <output:serialization-parameters>
              <output:method>json</output:method>
             </output:serialization-parameters>)
            }
        </script>
};

declare %templates:wrap function app:residences($node as node(), $model as map(*))
{
    let $expats := collection($config:data-root)//tei:listPerson[@xml:id='expats']/tei:person
    let $residences := $expats//tei:residence//tei:geo
    let $strings :=
        for $r in $residences return "[" || xs:string($r) || "]"
    return
    <script type="text/javascript">
        var MARKERS = [
        { string-join(subsequence($strings, 1, 200), ",")}
        ]
    </script>
    
};

declare 
    %rest:GET
    %rest:path("/mep/residences")
    %output:method("json")
function app:residences()
{
    let $expats := collection($config:data-root)//tei:listPerson[@xml:id='expats']/tei:person
    let $residences := $expats//tei:residence
    return
    <residences>{
    for $r in $residences
    return
       <residence>
       <viafid>{ $r/ancestor::tei:person/tei:idno[@type='viaf']/text() }</viafid>
       <name>{ $r/ancestor::tei:person/tei:persName/tei:surname[1]/text()  }</name>
       <latlon>{$r/tei:geo/text()}</latlon>
       </residence>
       }</residences>
};

declare 
    %rest:GET
    %rest:path("/mep/subscriptions")
    %output:method("text")
function app:logbooks-as-csv()
{
    let $xsl      := doc($config:app-root || "/resources/xsl/logbook2csv.xsl")
    let $events   := collection($config:data-root || "/transcriptions/logbooks")//tei:div[@type = 'day']
    
    return 
    (
        <rest:response>
            <http:response>
                <http:header name="access-control-allow-origin" value="*"/>
                <http:header name="Content-type" value="text/csv"/>
                <http:header name="charset" value="utf-8"/>
            </http:response>
        </rest:response>,
    transform:transform($events, $xsl, ())
    )
};

declare 
    %rest:GET
    %rest:path("/mep/subscriptions")
    %output:method("json")
    %rest:produces("application/json")
function app:logbooks-as-json()
{
    let $xsl      := doc($config:app-root || "/resources/xsl/logbook2xml.xsl")
    let $events   := collection($config:data-root || "/transcriptions/logbooks")//tei:div[@type = 'day']
    
    return 
    (
        <rest:response>
            <http:response>
                <http:header name="access-control-allow-origin" value="*"/>
                <http:header name="Content-type" value="application/json"/>
                <http:header name="charset" value="utf-8"/>
            </http:response>
        </rest:response>,
    transform:transform($events, $xsl, ())
    )
};

declare 
    %rest:GET
    %rest:path("/mep/subscriptions/calendar")
    %output:method("json")
    %rest:produces("application/json")
function app:subscription-calendar-as-json()
{
     
    (
        <rest:response>
            <http:response>
                <http:header name="access-control-allow-origin" value="*"/>
                <http:header name="Content-type" value="application/json"/>
                <http:header name="charset" value="utf-8"/>
            </http:response>
        </rest:response>,
    app:_calendar-chart-data()
    )
};

declare function app:_borrowed-items()
{
    collection($config:data-root)//tei:bibl[@ana="#borrowedItem"]
};

declare
    %rest:GET
    %rest:path('/mep/borrowed')
    %output:method("json")
function app:borrowed-items-as-json()
{
    let $bibls := app:_borrowed-items()
    return
    <borrowedItems> {
    for $bibl in $bibls
    let $borrower := $bibl/ancestor::tei:TEI/tei:teiHeader/tei:profileDesc/tei:particDesc/tei:person[@role='cardholder'][1]
    return
        <borrowedItem>
            <title>{ xs:string($bibl/tei:title[1]) }</title>
            <borrower>{ xs:string($borrower/tei:persName) }</borrower>
            <borrowerid>{ xs:string($borrower/@ana) }</borrowerid>
        </borrowedItem>
        }</borrowedItems>
};

declare function app:_borrowing-event-report()
{
let $core-titles    := ('mep:001p1r', 'mep:004j77', 'mep:002m04', 'mep:000r12', 'mep:002z2h')
let $core-cards:= collection($config:data-root || "/transcriptions/cards")//tei:TEI[.//tei:bibl[@corresp = $core-titles]]

let $records :=
for $card in $core-cards
let $person := $card//tei:person[@role='cardholder']
let $borrowed-items := $card//tei:bibl[@ana='#borrowedItem']
let $borrowing-events := $card//tei:ab[@ana='#borrowingEvent']
order by count($borrowed-items)
return
    <record>
        <name>{ $person[1]/tei:persName/text() }</name>
        <id>{ xs:string($person[1]/@ana) }</id>
        <borrowedItems>{ count($borrowed-items) }</borrowedItems>
        <borrowingEvents>{ count($borrowing-events) }</borrowingEvents>
        <uncoded>{ count($borrowed-items) - count($borrowing-events) }</uncoded>
    </record>
    
return <records>{ $records }</records>
};

(:~ Generates report for tracking progress of encoding core data set.
:)
declare
 %rest:GET
 %rest:path('/mep/report')
 %output:method("json")
 %rest:produces("application/json")
function app:borrowing-event-report-as-json()
{
app:_borrowing-event-report()
};

declare
 %rest:GET
 %rest:path('/mep/report')
 %output:method("text")
 %rest:produces("text/csv")
 function app:borrowing-event-report-as-csv()
 {
 let $records := app:_borrowing-event-report()
 return
 (
concat(string-join(('name', 'id', 'borrowedItems', 'borrowingEvents', 'uncoded'), ','), codepoints-to-string(10)),
for $r in $records/record
return 
concat(string-join(($r/name, $r/id, $r/borrowedItems, $r/borrowingEvents, $r/uncoded), ','), codepoints-to-string(10))
)
 };
 
declare function local:name-to-displayName($persName)
{
    let $surname :=
        if (count($persName/tei:surname) = 1)
            then $persName/tei:surname
        else if ($persName/tei:surname/@sort)
            then $persName/tei:surname[@sort = '1']
        else if (count($persName/tei:surname) > 1)
            then $persName/tei:surname[1]
        else "unknown"
        
     let $forename :=
        if (count($persName/tei:forename) = 1)
            then $persName/tei:forename
        else if (count($persName/tei:forename) > 1)
            then $persName/tei:forename[1]
        else ""
    return string-join((xs:string($forename[1]), xs:string($surname[1]) ), ' ')
};
 
declare function app:_subscribers()
 {
    let $persons := doc('/db/mep-data/transcriptions/personography.xml')//tei:person
    for $person in $persons
    order by $person/tei:persName[1]/tei:surname[1]
    return
       <person xml:id="{$person/@xml:id}">
           <displayName>{ local:name-to-displayName($person/tei:persName[1]) }</displayName>
       </person>
 };
 
declare function app:member($node as node(), $model as map(*), $id as xs:string)
as map(*)
{
    let $person := doc('/db/mep-data/transcriptions/personography.xml')//tei:person[@xml:id=$id]
        return
        map { "person" : $person  }
};

declare function app:member-name($node as node(), $model as map(*))
as xs:string
{
    local:name-to-displayName($model('person')/tei:persName)
};

declare function app:member-demographics($node as node(), $model as map(*))
as element()
{
    let $expat := $model('person')
    return
         <dl class="dl-horizontal">

                <dt>birth</dt>
                <dd>{ $expat/tei:birth }</dd>
                
                <dt>death</dt>
                <dd>{ $expat/tei:death }</dd>
                
                <dt>identified nationality</dt>
                <dd><ul class="list-inline">
                    {
                        for $nationality in $expat/tei:nationality
                        return <li>{ xs:string($nationality/@key) }</li>
                    }
                </ul></dd>
                
                <dt>extracted addresses</dt>
                <dd>{
                    let $residences := $expat/tei:residence
                    return
                        <ul class="list-unstyled">
                        { 
                            for $residence in $residences return <li>{ $residence }</li>
                        }
                        </ul>
                }</dd>
                
                <dt>see also</dt>
                <dd>{ 
                    let $viafnum := $expat/tei:idno[@type='viaf']
                    let $link    := 'http://viaf.org/viaf/' || $viafnum
                    return
                    <a href="{$link}">{ $link }</a>                
                }</dd>
                
                </dl>
};

declare function app:member-subscription-history($node as node(), $model as map(*))
as element()
{
    let $subscriberid := $model('person')/@xml:id
    let $events :=
        collection('/db/mep-data/transcriptions/logbooks')//tei:event[.//tei:persName/@ref = "#"||$subscriberid]
    return 
    <table class="table">
        <tr>
            <th>date</th>
            <th>type</th>
        </tr>
{ for $e in $events 
  let $type := xs:string($e/@type)
  let $date := $e/ancestor::tei:div[@type='day']/tei:head/tei:date/@when-iso
  order by $date
return 
<tr>
    <td>{ xs:string($date) }</td>
    <td>{ $type }</td>
</tr>
}
</table>
};

declare function app:member-borrowing-history($node as node(), $model as map(*))
as element()
{
    let $subscriberid := $model('person')/@xml:id
    let $cards := collection('/db/mep-data/transcriptions/cards')//tei:person[@role = 'cardholder' and @ana = "#"||$subscriberid]/ancestor::tei:TEI
    let $borrowing-events := $cards//tei:ab[@ana = '#borrowingEvent']
    return
    <table class="table">
        <tr>
            <th>checked out</th>
            <th>item</th>
            <th>returned</th>
        </tr>
        {
        for $e in $borrowing-events
        let $checked-out := $e/tei:date[@ana='#checkedOut']
        let $item := $e//tei:bibl[@ana='#borrowedItem']
        let $itemid := $item/@corresp
        let $item-title :=
            if ($itemid) then
              doc('/db/mep-data/borrowed-titles.xml')//row[titleid=$itemid][1]/regularized_title
            else $e//tei:bibl[@ana='#borrowedItem']/tei:title
        let $returned := $e/tei:date[@ana='#returned']
        return
          <tr>
            <td>{ if ($checked-out) then xs:string($checked-out/@when) else () }</td>
            <td>{ if ($itemid) then <a href="book.html?id={$itemid}">{$item-title }</a> else $item-title }</td>
            <td>{ if ($returned) then xs:string($returned/@when) else () }</td>
          </tr>
        }
    </table>
};


declare %templates:wrap function app:books($node as node(), $model as map(*))
{
    let $source := doc('/db/mep-data/borrowed-titles.xml')
    let $bookids := distinct-values($source//titleid)
    let $books :=
        for $id in $bookids return 
             $source//row[titleid=$id][1]
    return map { "books" : $books }
};

declare %templates:wrap function app:book-list($node as node(), $model as map(*))
{
    <ul> {
    for $book in $model('books')
    return <li><a href="book.html?id={$book/titleid}">{ $book/regularized_title }</a></li>
    } </ul>
};

declare %templates:wrap function app:selected-book($node as node(), $model as map(*), $id as xs:string)
{
    map { 'selected-book' : doc('/db/mep-data/borrowed-titles.xml')//row[titleid=$id][1] }
};

declare %templates:wrap function app:selected-book-title($node as node(), $model as map(*), $id as xs:string)
{
    $model('selected-book')/regularized_title/text()
};

declare %templates:wrap function app:book-borrowing-events($node as node(), $model as map(*), $id as xs:string)
{
    let $bookid := xs:string($model('selected-book')/titleid)
    let $events := collection($config:data-root)//tei:ab[@ana="#borrowingEvent"][tei:bibl/@corresp = $bookid]
    for $event in $events
        let $checkedOut := $event/tei:date[@ana='#checkedOut']
        let $checkedOutLabel :=
            if ($checkedOut/@when)
                then if (matches($checkedOut/@when, '^1900')) then 'undetermined'
                else xs:string($checkedOut/@when)
            else if ($checkedOut/@not-before)
                then "not before " || xs:string($checkedOut/@not-before)
            else if ($checkedOut/@not-after)
                then "not after " || xs:string($checkedOut/@not-after)
            else xs:string($checkedOut)
        let $returned   := $event/tei:date[@ana='#returned']
        let $returnedLabel :=
            if ($returned/@when)
                then if (matches($returned/@when, '^1900')) then 'undetermined'
                else xs:string($returned/@when)
            else if ($returned/@not-before)
                then "not before " || xs:string($returned/@not-before)
            else if ($returned/@not-after)
                then "not after " || xs:string($returned/@not-after)
            else xs:string($returned)
        
        
        let $borrower   := $event/ancestor::tei:TEI//tei:particDesc/tei:person[@role = 'cardholder']
        order by $checkedOutLabel
        return
         <tr>
            <td><a href="member.html?id={substring-after($borrower/@ana, '#')}">{ xs:string($borrower) }</a></td>
            <td>{ $checkedOutLabel }</td>
            <td>{ $returnedLabel }</td>
         </tr>
};

declare
  %rest:GET
  %rest:path('mep/subscribers')
function app:subscribers()
{
    <persons>
    { app:_subscribers() }
    </persons>
};

declare function local:duration($event)
{
    let $event-duration := $event//tei:measure[@type='duration']
    let $unit := $event-duration/@unit
    let $quantity :=  $event-duration/@quantity
    return
    switch($unit)
        case "month" return xs:yearMonthDuration(concat('P', $quantity, 'M'))
        case "year" return xs:yearMonthDuration(concat('P', $quantity, 'Y'))
        case "day" return xs:dayTimeDuration(concat('P', $quantity, 'D'))
        default return error((), "invalid duration unit")
};

declare function local:subscriptions()
{

for $event in collection('/db/mep-data/transcriptions/logbooks')//tei:event[(@type = 'subscription' or @type='renewal') and exists(.//tei:measure[@type='duration'])]
let $start := $event/ancestor::tei:div[@type = 'day'][1]/tei:head/tei:date/@when-iso
let $duration := local:duration($event)
return
        <subscription subscriber = "{$event//tei:persName/@ref}"
        start="{$start}" end="{xs:date($start) + $duration}">
        </subscription>
};