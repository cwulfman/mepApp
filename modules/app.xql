xquery version "3.0";

module namespace app="http://digitalhumanities.princeton.edu/mep/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://digitalhumanities.princeton.edu/mep/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";


declare
    %templates:wrap
function app:sex-distribution($node as node(), $model as map(*))
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

declare %templates:wrap function app:national-distribution($node as node(), $model as map(*))
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
    let $events   := collection($config:data-root || "/transcriptions/logbooks")//tei:div[@type = 'day']
    
    return transform:transform($events, $xsl, ())
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



