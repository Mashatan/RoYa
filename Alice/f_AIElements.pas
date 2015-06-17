{This unit contains classes to process template elements}
unit f_AIElements;

interface
implementation
uses
  f_AIElementFActory,f_AIPatternMatcher,f_AIVariables,f_AIAIMLLoader,f_AITemplateProcessor,
  LibXMLParser,SysUtils,classes,f_AIUtils;

type
  TAIBotElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIxStarElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIGetElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAISetElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIDefaultElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAILearnElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAISrElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIThinkElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAISraiElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIRandomElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIBrElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIConditionElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    function blockCondition(variable,value:string;Match:TMatch;Parser:TXMLParser):string;
    function blockSwitch(variable:string;Match:TMatch;Parser:TXMLParser):string;
    //function blockMulti(Match:TMatch;Parser:TXMLParser):string;
    procedure register;override;
  end;

  TAICaseElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;


  TAIThatElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIVersionElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIidElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAISizeElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIDateElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIGossipElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIInputElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAISubstElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIJScriptElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAISystemElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;

  TAIForgetElement=class(TAITemplateElement)
    function Process(Match:TMatch;Parser:TXMLParser):string;override;
    procedure register;override;
  end;


  function TAISetElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      name:string;
    begin
      name:=parser.CurAttr.Value('name');
      result:=ProcessContents(Match,Parser);
      result:=TrimWS(ConvertWs(result,true));
      Memory.setVar(name,result);
    end;
  procedure TAISetElement.register;
    begin
      ElementFactory.register('set',self);
    end;

  function TAIBotElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Memory.getProp(parser.CurAttr.Value('name'));
    end;
  procedure TAIBotElement.register;
    begin
      ElementFactory.register('bot',Self);
    end;
  function TAIGetElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Memory.getVar(parser.CurAttr.Value('name'));
      if (Parser.CurPartType=ptEmptyTag) or
         (Parser.CurPartType=ptEndTag) then exit;
      if result<>'' then
        repeat until
          (not parser.Scan)or
          ((parser.CurPartType=ptEndTag)and
           (parser.CurName='get'))
      else
        result:=ProcessContents(Match,Parser);
    end;
  procedure TAIGetElement.register;
    begin
      ElementFactory.register('get',Self);
    end;

  function TAIxStarElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      context:integer;
      index:string;
    begin
      if parser.CurPartType<>ptEndTag then begin
        if parser.CurName='star' then context:=0;
        if parser.CurName='thatstar' then context:=1;
        if parser.CurName='topicstar' then context:=2;
        index:=Parser.CurAttr.Value('index');
        if index='' then index:='1';
        result:=Match.get(context,strtoint(index));
        result:=TrimWS(result);
      end else
        result:='';
    end;
  procedure TAIxStarElement.register;
    begin
      ElementFactory.register('star',self);
      ElementFactory.register('thatstar',self);
      ElementFactory.register('topicstar',self);
    end;

  function TAIDefaultElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      SetLength(result,Parser.CurFinal-Parser.CurStart+1);
      result:=StrLCopy(PCHar(result),Parser.CurStart,Parser.CurFinal-Parser.CurStart+1);
    end;
  procedure TAIDefaultElement.register;
    begin
      ElementFactory.registerdefault(Self);
      ElementFactory.register('default',self);
    end;

  function TAILearnElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='';
      if parser.CurPartType=ptEmptyTag then exit;
      result:=ProcessContents(Match,Parser);
      if not assigned(AIMLLoader) then AIMLLoader:=TAIMLLoader.Create('');
      AIMLLoader.load(result);
    end;
  procedure TAILearnElement.register;
    begin
      ElementFactory.register('learn',Self);
    end;

  function TAISrElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      temp:TMatch;
    begin
      temp:=PatternMatcher.Matchinput(Match.get(0,1));
      result:=TemplateProcessor.Process(temp);
      temp.free;
      if parser.curPartType=ptStartTag then
      while (parser.scan) and (parser.curparttype<>ptEndTag) and (parser.curName<>'sr') do;
    end;
  procedure TAISrElement.register;
    begin
      ElementFactory.register('sr',Self);
    end;

  function TAIThinkElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      ProcessContents(Match,Parser);
      result:='';
    end;
  procedure TAIThinkElement.register;
    begin
      ElementFactory.register('think',Self);
    end;
  function TAISraiElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      temp:TMatch;
    begin
      result:=ProcessContents(Match,Parser);
      if result='' then begin
        temp:=PatternMatcher.Matchinput(Match.get(0,1));
        result:=TemplateProcessor.Process(temp);
        temp.free;
      end else begin
        temp:=PatternMatcher.Matchinput(result);
        result:=TemplateProcessor.Process(temp);
        temp.free;
      end;
    end;
  procedure TAISraiElement.register;
    begin
      ElementFactory.register('srai',Self);
    end;

  function TAIRandomElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      Options:Tlist;
      //Start:PChar;
      continue:PChar;
      //i:integer;
    begin
      Options:=Tlist.Create;
      result:='';
      While parser.Scan do begin
        case parser.CurPartType of
          ptStartTag:if (parser.CurName='li') then begin
                         Options.Add(Parser.CurFinal);
                         SkipElement(Parser);
                     end;
          ptEndTag:if (parser.CurName='random') then break;
        end;
      end;
      continue:=parser.curfinal;

      Parser.CurFinal:=Options[random(options.count)];
      Parser.CurName:='li';
      result:=ProcessContents(Match,Parser);
      Options.Free;
      parser.CurFinal:=Continue;
    end;
  procedure TAIRandomElement.register;
    begin
      Randomize;
      ElementFactory.register('random',Self);
    end;

  function TAIConditionElement.blockCondition(variable,value:string;Match:TMatch;Parser:TXMLParser):string;
    begin
      if AnsiCompareStr(Memory.getVar(variable),value)=0 then begin
        result:=ProcessContents(Match,Parser);
      end else begin
        result:='';
        SkipElement(Parser);
      end;
    end;
  function TAIConditionElement.blockSwitch(variable:string;Match:TMatch;Parser:TXMLParser):string;

    var
      curval:string;
      curvar:string;
      defaultitem:boolean;
      nvItem:boolean; {<li name="xx" value=""></li>}
      vItem:boolean;  {<li name="xx" value=""></li>}
    begin
      result:='';
      While (Parser.Scan) do begin
        case parser.CurPartType of
          ptStartTag,
          ptEmptyTag:if parser.CurName='li' then begin
                       curval:=Parser.CurAttr.Value('value');
                       curvar:=Parser.CurAttr.Value('name');
                       defaultItem:=(Parser.CurAttr.Count= 0);
                       nvItem:=(Parser.CurAttr.Count= 2)and AnsiSameStr(Memory.getVar(curvar),curval);
                       vItem:=(variable<>'') and AnsiSameStr(Memory.getVar(variable),curval);
                       if (defaultItem or nvItem or vItem)
                       then begin
                         result:=ProcessContents(Match,Parser);
                         SkipElement('condition',parser);
                         break;
                       end else
                         SkipElement(parser);
                     end;
        end;
      end;
    end;
  function TAIConditionElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      mainval:string;
      mainvar:string;
    begin
      mainval:=Parser.CurAttr.Value('value');
      mainvar:=Parser.CurAttr.Value('name');
      if (mainvar<>'') and (Parser.CurAttr.Node('value')<>nil) then begin
        result:=blockCondition(mainvar,mainval,Match,Parser);
      end else if (mainval='') then begin
        result:=blockSwitch(mainvar,Match,Parser);
      end;
    end;
  procedure TAIConditionElement.register;
    begin
      ElementFactory.register('condition',Self);
    end;
  function TAIBrElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=' ';
    end;
  procedure TAIBrElement.register;
    begin
      ElementFactory.register('br',Self);
    end;

  function TAICaseElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      specificElement:string;
      upstr:string;
      i:integer;
    begin
      result:='';
      specificElement:=Parser.Curname;
      result:=ProcessContents(MAtch,Parser);
      result:=convertWS(result,true);
      if SpecificElement='uppercase' then
        result:=AnsiUpperCase(result)
      else if SpecificElement='lowercase' then
        result:=AnsiLowerCase(result)
      else if (SpecificElement='formal') and (result<>'')then begin
        upstr:=AnsiUpperCase(result);
        result[1]:=upstr[1];
        for i:=1 to length(result)-1 do
          if result[i]=' ' then
            result[i+1]:=upstr[i+1];
      end else if SpecificElement='sentence' then
        result[1]:=AnsiUpperCase(result)[1];
    end;
  procedure TAICaseElement.register;
    begin
      ElementFactory.register('uppercase',Self);
      ElementFactory.register('lowercase',Self);
      ElementFactory.register('formal',Self);
      ElementFactory.register('sentence',Self);
    end;

  function TAIThatElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      thisTag:string;
    begin
      ThisTag:=Parser.CurName;
      if ThisTag='botsaid' then thistag:='that';
      if Parser.CurAttr.Count<>0 then result :=''
      else if ThisTag='that' then
        result:=Memory.getVar('that')
      else if ThisTag='justbeforethat' then
        result:=Memory.getVar('that',1);

      SkipElement(parser);
    end;
  procedure TAIThatElement.register;
    begin
      ElementFactory.register('that',Self);
      ElementFactory.register('justbeforethat',Self);
      ElementFactory.register('botsaid',Self);
    end;

  function TAIVersionElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='PASCAlice v1.5';
      SkipElement(Parser);
    end;
  procedure TAIVersionElement.register;
    begin
      ElementFactory.register('version',Self);
      ElementFactory.register('getversion',Self);
    end;

  function TAIIdElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='0';
      SkipElement(Parser);
    end;
  procedure TAIIdElement.register;
    begin
      ElementFactory.register('id',Self);
      ElementFactory.register('get_ip',Self);
    end;

  function TAISizeElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=inttostr(PatternMatcher._count);
      SkipElement(Parser);
    end;
  procedure TAISizeElement.register;
    begin
      ElementFactory.register('size',Self);
      ElementFactory.register('getsize',Self);
    end;

  function TAIDateElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=DatetoStr(now);
      skipElement(parser);
    end;
  procedure TAIDateElement.register;
    begin
      ElementFactory.register('date',Self);
    end;

  function TAIGossipElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=ProcessContents(Match,Parser);
      WrFile('gossip.log',result);
    end;
  procedure TAIGossipElement.register;
    begin
      ElementFactory.register('gossip',Self);
    end;

  function TAIInputElement.Process(Match:TMatch;Parser:TXMLParser):string;
    var
      thisTag:string;
      i:integer;
      si:string;
    begin
      ThisTag:=Parser.CurName;
      SkipElement(Parser);

      if ThisTag='input' then begin
        si:=Parser.CurAttr.Value('index');
        if si<>'' then
          i:=strtoint(si)-1
        else
          i:=0;
        result:=Memory.getVar('input',i)
      end else if ThisTag='justthat' then
        result:=Memory.getVar('input',1)
      else if ThisTag='beforethat' then
        result:=Memory.getVar('input',2);

    end;
  procedure TAIInputElement.register;
    begin
      ElementFactory.register('input',Self);
      ElementFactory.register('justthat',Self);
      ElementFactory.register('beforethat',Self);
    end;
  function TAISubstElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      if parser.CurPartType=ptEmptyTag then
        result:=Match.get(0,1)
      else
        result:='';
    end;
  procedure TAISubstElement.register;
    begin
      ElementFactory.register('person',Self);
      ElementFactory.register('person2',Self);
      ElementFactory.register('gender',Self);
    end;
  function TAIJScriptElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Parser.CurAttr.Value('alt');
      SkipElement(parser);
    end;
  procedure TAIJScriptElement.register;
    begin
      ElementFactory.register('javascript',Self);
    end;
  function TAISystemElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:=Parser.CurAttr.Value('alt');;
      if result<>'' then SkipElement(parser);
    end;
  procedure TAISystemElement.register;
    begin
      ElementFactory.register('system',Self);
    end;

  function TAIForgetElement.Process(Match:TMatch;Parser:TXMLParser):string;
    begin
      result:='';
      SkipElement(parser);
      Memory.ClearVars;
    end;
  procedure TAIForgetElement.register;
    begin
      ElementFactory.register('forget',Self);
    end;

begin
  if not assigned(ElementFactory) then
  ElementFactory:=TAIElementFactory.Create;
  TAIBotElement.Create;
  TAIDefaultElement.Create;
  TAIGetElement.Create;
  TAIxStarElement.Create;
  TAILearnElement.Create;
  TAISetElement.Create;
  TAISrElement.Create;
  TAIThinkElement.Create;
  TAISraiElement.Create;
  TAIRandomElement.Create;
  TAIConditionElement.Create;
  TAIBrElement.Create;
  TAICaseElement.Create;
  TAIThatElement.Create;
  TAIVersionElement.Create;
  TAIIdElement.Create;
  TAISizeElement.Create;
  TAIDateElement.Create;
  TAIGossipElement.Create;
  TAIInputElement.Create;
  TAIsubstElement.Create;
  TAIJscriptElement.Create;
  TAIsystemElement.Create;
  TAIForgetElement.Create;
end.
