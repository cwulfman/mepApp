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

declare function app:cards($node as node(), $model as map(*))
{
    let $cards := collection('/db/mep-data/transcriptions')//tei:TEI[tei:teiHeader//tei:classCode='300026802']
    return map { "cards" : $cards }
};

declare   %templates:wrap function app:cardholders($node as node(), $model as map(*))
{
    <ul> {
    for $card in $model('cards')
    let $person := $card/tei:teiHeader//tei:particDesc/tei:person[@role = 'cardholder']
    return
        <li>{ $person }</li>
    }</ul>
};