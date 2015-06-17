unit f_AIBotLoader;

interface
uses LibXMLParser,f_AIAIMLLoader,classes, f_AIPatternMatcher;
type
  TBotLoader=class
    loaded:boolean;
    parser:TXmlParser;

    procedure load(filename:string);
    Function BotElement:boolean;
    function SentenceSplitters:boolean;
    function InputSubstitutions:boolean;
    Function PropertyElement:boolean;
    Function LearnElement:boolean;
  end;
var
  Botloader:TBotLoader;
implementation
  uses SysUtils,f_AIVariables,f_AIUtils;
  function TBotLoader.PropertyElement:boolean;
    var
      prop,val:string;
    begin
      result:=true;
      prop:=Parser.CurAttr.Value('name');
      val:=Parser.CurAttr.Value('value');

      if (prop='') or (val ='') then
        result:=false
      else begin
        Memory.setProp(prop,val);
        //log.Log('botloader','Bot property '+prop+'="'+val+'"'); // Commented by Ali Mashatan 2008/08/24
      end;
      SkipElement(Parser);
    end;
  function TBotLoader.LearnElement:boolean;
    begin
      While parser.scan do
        if (parser.CurPartType=ptEndTag)and(parser.Curname='learn') then
          break;
      if Parser.CurContent<>'' then begin
        AIMLLoader.load(Parser.CurContent);
        loaded:=true;
        result:=true;
      end else
        result:=false;

    end;
  function TBotLoader.BotElement:boolean;
    var
      numprops:integer;
      bot_ID:string;
    begin
      result:=true;
      numprops:=0;
      bot_ID:=Parser.CurAttr.Value('id');
      if AnsiSameStr(Parser.CurAttr.Value('enabled'),'false') then Begin
        skipElement(parser);
        exit;
      end;
      //Memory.bot_ID:=bot_ID; // Commented by Ali Mashatan 2008/08/24
      //Memory.Load;           // Commented by Ali Mashatan 2008/08/24
      while (parser.scan) do
        case Parser.CurPartType of
          ptStartTag,
          ptEmptyTag:begin
                       if parser.CurName='property' then begin
                         if PropertyElement then inc(numprops);
                       end else
                       if parser.CurName='learn' then
                         LearnElement;
                     end;
          ptEndTag:if parser.curname='bot' then break;
        end;
    end;
  function TBotLoader.SentenceSplitters:boolean;
    var
      val:string;
      count:integer;
    begin
      count:=0;
      result:=true;
      if parser.CurPartType=ptEmptyTag then exit;
      while Parser.Scan do
        case Parser.CurPartType of
          ptStartTag,
          ptEmptyTag:if parser.Curname='splitter' then begin
                       val:=Parser.CurAttr.Value('value');
                       if val<>'' then SentenceSplitterChars:=SentenceSplitterChars+val;
                       inc(count);
                     end;
          ptEndTag:if parser.CurName='sentence-splitters' then break;
        end;
      //Log('botloader','Loaded '+inttostr(count)+' sentence splitters'); // Commented by Ali Mashatan 2008/08/24
    end;
  function TBotLoader.InputSubstitutions:boolean;
    var
      _from,_to:string;
      count:integer;
    begin
      count:=0;
      result:=true;
      if parser.CurPartType=ptEmptyTag then exit;
      while Parser.Scan do
        case Parser.CurPartType of
          ptStartTag,
          ptEmptyTag:if parser.Curname='substitute' then begin
                       _from:=Parser.CurAttr.Value('find');
                       _to:=Parser.CurAttr.Value('replace');
                       Preprocessor.add(_from,_to);
                       inc(count);
                     end;
          ptEndTag:if parser.CurName='input' then break;
        end;
      //Log('botloader','Loaded '+inttostr(count)+' input substitutions'); // Commented by Ali Mashatan 2008/08/24
    end;

  procedure TBotLoader.load(filename:string);
    begin
      if loaded then Begin
        exit; {don't load 2 bots at 1 time}
      end;
      parser:=TXmlParser.Create;
      parser.Normalize:=true;
      parser.LoadFromFile(filename);
      parser.startscan;
      while parser.Scan do
        case parser.CurPartType of
          ptStartTag:if parser.CurName='bot' then BotElement else
                     if parser.CurName='sentence-splitters' then SentenceSplitters else
                     if parser.CurName='input' then InputSubstitutions;
        end;
      parser.clear;
      parser.free;
    end;

end.
