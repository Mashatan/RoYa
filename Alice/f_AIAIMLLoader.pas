unit f_AIAIMLLoader;

interface
uses f_AIPatternMatcher,LibXmlParser;
type

  TAIMLLoader=class
   private
     Path:String;
   public
    _pattern,
    _that,
    _topic:string;

    _template:string;
    parser:TXmlParser;
    constructor Create(pPath:String);
    procedure load(filename:string);
    procedure TopicStart;
    procedure TopicEnd;
    procedure That;
    procedure CategoryStart;
    Procedure CategoryEnd;

    function PatternElement:boolean;
    function ThatElement:boolean;
    function TemplateElement:boolean;
    function PatternBotElement:boolean;
    function CategoryElement:boolean;
    function AIMLElement:boolean;
  end;
var
  AIMLLoader:TAIMLLoader;

implementation
  uses SysUtils,f_AIVariables;

  const max_content_size=20480;

  constructor TAIMLLoader.Create(pPath: String);
    begin
       if pPath<>'' then
         path:=pPath;
    end;

  Procedure TAIMLLoader.TopicStart;
    begin
      _topic:=parser.CurAttr.Value('name');
    end;

  Procedure TAIMLLoader.TopicEnd;
    begin
      _topic:='*';
    end;
  Procedure TAIMLLoader.That;
    begin
      _That:=parser.CurContent;
    end;
  Procedure TAImlLoader.CategoryStart;
    begin
      _pattern:='';
      _that:='';
      _template:='';
    end;
  Procedure TAImlLoader.CategoryEnd;
    begin
      if _pattern='' then _pattern:='*';
      if _that='' then _that:='*';
      PatternMatcher.add(_pattern+' <that> '+_that+' <topic> '+_topic,_template);

    end;
  function TAIMLLoader.PatternBotElement:boolean;
    var
      prop:string;
    begin
      prop:=Memory.getProp(parser.CurAttr.Value('name'));
      if prop='' then
        result:=false
      else begin
        _Pattern:=_pattern+' '+Prop;
        result:=true;
      end;
    end;
  function TAIMLLoader.PatternElement:boolean;
    begin
      _pattern:='';
      result:=true;
      while (result)and(Parser.Scan) do begin
        case Parser.CurPartType of
          ptContent:_pattern:=_pattern+' '+Parser.CurContent;
          ptEmptyTag: if (Parser.CurName='bot') then
                        result:=PAtternBotElement
                      else
                        result:=false;
          ptEndTag: if (Parser.CurName='pattern') then break
                    else result:=false;
          ptComment:;
        else
          result:=false;
        end;
      end;
    end;
  function TAIMLLoader.ThatElement:boolean;
    begin
      _that:='';
      result:=true;
      while (result)and(Parser.Scan)  do begin
        case Parser.CurPartType of
          ptContent:_that:=_that+' '+Parser.CurContent;
          ptEndTag: if (Parser.CurName='that') then break
                    else result:=false;
          ptComment:;
        else
          result:=false;
        end;
      end;
      if _that='' then _that:='*';
    end;
  function TAIMLLoader.TemplateElement:boolean;
    var
      start:Pchar;
      done:boolean;
    begin
      _template:='';
      start:=Parser.CurFinal+1;
      done:=false;
      while (not done) and (parser.scan) do
        done:=(Parser.CurPartType=ptEndTag) and (Parser.CurName='template');
      if done then begin
        SetLength(_template,Parser.CurStart-start);
        _template:=StrLCopy(PCHar(_template),start,Parser.CurStart-start);
        result:=true;
      end else
        result:=false;
    end;
  function TAIMLLoader.CategoryElement:boolean;

    begin
      result:=true;
      _that:='*';
      while (result)and(parser.Scan) do
        case parser.CurPartType of
          ptStartTag:begin
            if parser.CurName='template' then result:=TemplateElement else
            if parser.CurName='pattern' then result:=PatternElement else
            if parser.CurName='that' then result:=ThatElement;
          end;
          ptEndTag: begin
            if parser.CurName='category' then break;
          end;
        end;
      if result then begin
        if _that='' then _that:='*';
        PatternMatcher.add(_pattern+' <that> '+_that+' <topic> '+_topic,_template);
      end else
        while not ((Parser.CurPartType=ptEndTag) and (Parser.CurName='category')) do
          parser.Scan;
      //if (PatternMatcher._count mod 5000)=0 then // Commented by Ali Mashatan 2008/08/24
            //log.Log('aimlloader',Inttostr(PatternMatcher._count)+' categories...'); // Commented by Ali Mashatan 2008/08/24
    end;
  function TAIMLLoader.AIMLElement:boolean;
    begin
      _topic:='*';
      result:=true;
      while (result)and(parser.Scan) do
        case parser.CurPartType of
          ptStartTag:begin
            if parser.CurName='category' then CategoryElement else
            if parser.CurName='topic' then Topicstart;
          end;
          ptEndTag: begin
            if parser.CurName='topic' then TopicEnd else
            if parser.CurName='aiml' then break;
          end;
        end;
    end;

  procedure TAIMLLoader.load(filename:string);
    var
      search:TSearchRec;
      dir:string;
      name,PathFile:string;
      i:integer;
    begin
      parser:=TXmlParser.Create;
      parser.Normalize:=true;
      for i:=1 to length(filename) do
        if filename[i]='/' then filename[i]:='\';
      PathFile:=path+filename;
      dir:=ExtractFilePath(PathFile);
      if findfirst(PathFile,0,search) =0 then
        repeat
          name:=dir+Search.Name;
          if not FileExists(name) then begin
            continue;
          end;
          parser.LoadFromFile(Name);
          parser.startscan;
          while parser.Scan do
            case parser.CurPartType of
              ptStartTag:if parser.CurName='aiml' then AIMLElement;
            end;
          parser.clear;
        until FindNext(search)<>0;
      FindClose(search);
      parser.free;
    end;

end.
