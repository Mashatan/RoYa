unit f_AIElementFactory;

interface
uses LibXMLParser,f_AIPatternMatcher,classes;
type
  {abstract base class for all template elements}
  TAITemplateElement=class
    constructor Create;
    procedure Register;virtual;abstract;
    function Process(Match:TMatch;Parser:TXMLParser):string;virtual;abstract;
  end;

  {this is a container class that returns an instance of a template processing element}
  TAIElementFactory=class
    _Elements:TStringList;
    _default:TAITemplateElement;
    constructor Create;
    destructor Destroy; override;
    procedure register(name:string;Element:TAITemplateElement);

    procedure registerdefault(element:TAITemplateElement);
    function get(name:string):TAITemplateElement;
  end;



var
  ElementFactory:TAIElementFactory;

implementation

  constructor TAITemplateElement.Create;
    begin
      inherited create;
      register;
    end;
  constructor TAIElementFactory.Create;
    begin
      _Elements:=TStringlist.Create;
      _Elements.Sorted:=True;
    end;
  Destructor TAIElementFactory.Destroy;
    var
      i:integer;
      j:integer;
      this:TObject;
    begin
      for i:=0 to _Elements.Count-1 do
        if assigned(_Elements.Objects[i]) then begin {frees the current instance, and removes all references to it}
          This:=_Elements.Objects[i];
          _Elements.Objects[i].Free;
          for j:=i+1 to _Elements.Count-1 do
            if _Elements.Objects[j]=this then _Elements.Objects[j]:=nil;
        end;
      _Elements.Free;
      inherited destroy;
    end;
  Procedure TAIElementFactory.register(name:string;Element:TAITemplateElement);
    begin
      _Elements.AddObject(name,Element);
    end;
  Procedure TAIElementFactory.registerdefault(Element:TAITemplateElement);
    begin
      _default:=Element;
    end;
  function TAIElementFactory.get(name:string):TAITemplateElement;
    var
      i:integer;
    begin
      if _Elements.Find(name,i) then
        result:=_elements.Objects[i] as TAITemplateElement
      else
        result:=_default;
    end;
initialization
  if not assigned(ElementFactory) then
  ElementFactory:=TAIElementFactory.Create;
finalization
  if  assigned(ElementFactory) then
    ElementFactory.Free;
end.
