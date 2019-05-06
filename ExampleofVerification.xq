import module namespace sw="Semantic Web" at "SemanticWeb.xq";
import module namespace swrle="Semantic Web Rule Language Engine" at "SWRL.xq";

declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace xsd="http://www.w3.org/2001/XMLSchema#";
declare namespace swrl="http://www.w3.org/2003/11/swrl#";


let $name := /conference 
 let $ontology1 :=
(for $x in $name/papers/paper return sw:toClassFiller(concat('#',$x/@id),"#Paper") union sw:toDataFiller(concat('#',$x/@id),"studentPaper",$x/@studentPaper,"boolean") union sw:toDataFiller(concat('#',$x/@id),"title",$x/title,"string") union sw:toDataFiller(concat('#',$x/@id),"wordCount",$x/wordCount,"integer")
) 
let $ontology2 :=
(for $y in $name/researchers/researcher return sw:toClassFiller(concat('#',$y/@id),"#Researcher") union sw:toDataFiller(concat('#',$y/@id),"name",$y/name,"string") union sw:toDataFiller(concat('#',$y/@id),"isStudent",$y/@isStudent,"boolean") union sw:toObjectFiller(concat('#',$y/@id),"manuscript",concat('#',$y/@manuscript)) union sw:toObjectFiller(concat('#',$y/@id),"referee",concat('#',$y/@referee)))
return   
let $mapping := $ontology1 union $ontology2
let $rule1 := swrle:Imp(
swrle:AtomList(swrle:IndividualPropertyAtom("#referee","#x","#y")),
swrle:AtomList(swrle:IndividualPropertyAtom("#submission","#x","#y")))
let $rule2 := swrle:Imp(
swrle:AtomList(swrle:IndividualPropertyAtom("#manuscript","#x","#y")),
swrle:AtomList(swrle:IndividualPropertyAtom("#author","#y","#x")))
let $rule3 := swrle:Imp(
swrle:AtomList(swrle:DatavaluedPropertyAtomValue("#isStudent","#x","true","http://www.w3.org/2001/XMLSchema#boolean")),
swrle:AtomList(swrle:ClassAtom("#Student","#x")))
let $ruleall := $rule1 union $rule2 union $rule3
return 
let $completion := swrle:swrl(<rdf:RDF> {$mapping} </rdf:RDF>,<rdf:RDF> {$ruleall} </rdf:RDF>)
return 
let $integrity1 :=
swrle:Imp(
swrle:AtomList((swrle:DatavaluedPropertyAtomVars("#wordCount","#x","#y"),swrle:BuiltinAtomArg2("http://www.w3.org/2003/11/swrlb#greaterThanOrEqual","#y","10000","http://www.w3.org/2001/XMLSchema#integer"))),
swrle:AtomList(swrle:ClassAtom("#PaperLength","#x")))
let $integrity2 := 
swrle:Imp(
swrle:AtomList((swrle:IndividualPropertyAtom("#manuscript","#x","#y"),
swrle:IndividualPropertyAtom("#submission","#x","#y"))),
swrle:AtomList(swrle:ClassAtom("#NoSelfReviews","#x")))
let $integrity3 := 
swrle:Imp(
swrle:AtomList((swrle:ClassAtom("#Student","#x"),
swrle:IndividualPropertyAtom("#submission","#x","#y"))),
swrle:AtomList(swrle:ClassAtom("#NoStudentReviewers","#x")))
let $integrity4 := swrle:Imp(
swrle:AtomList((swrle:IndividualPropertyAtom("#manuscript","#x","#y"),
swrle:DatavaluedPropertyAtomValue("#isStudent","#x","true","http://www.w3.org/2001/XMLSchema#boolean"),
swrle:DatavaluedPropertyAtomValue("#studentPaper","#y","false","http://www.w3.org/2001/XMLSchema#boolean"))),
swrle:AtomList(swrle:ClassAtom("#BadPaperCategory","#x")))
let $integrity5 := swrle:Imp(
swrle:AtomList((swrle:IndividualPropertyAtom("#author","#x","#y"),
swrle:DatavaluedPropertyAtomValue("#isStudent","#y","true","http://www.w3.org/2001/XMLSchema#boolean"),
swrle:DatavaluedPropertyAtomValue("#studentPaper","#x","false","http://www.w3.org/2001/XMLSchema#boolean"))),
swrle:AtomList(swrle:ClassAtom("#BadPaperCategory","#x")))
let $integrityall := $integrity1 union $integrity2 union $integrity3 union $integrity4 union $integrity5
return swrle:swrl(<rdf:RDF> {$mapping union $completion} </rdf:RDF>,<rdf:RDF> {$integrityall} </rdf:RDF>)
