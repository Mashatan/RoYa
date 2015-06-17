{
   File: f_IMAlice

   Project:  RoYa
   Status:   Version 4.0 
   Date:     2008-09-04
   Author:   Ali Mashatan

   License:
     GNU Public License ( GPL3 ) [http://www.gnu.org/licenses/gpl-3.0.txt]
     Copyrigth (c) Mashatan Software 2002-2008

   Contact Details:
     If you use RoYa I would like to hear from you: please email me
     your comments - good and bad.
     E-mail:  ali.mashatan@gmail.com 
     website: https://github.com/Mashatan

   Change History:
   Date         Author       Description
}
unit f_IMAlice;

interface
 uses Classes, SysUtils ,LibXMLParser, ExtCtrls,f_IMCommon,f_AIBotloader,f_AIUtils,f_IMBuffer;

type
  TIMAlice=Class(TThread)
   private
     fAliceBuffer:TIMBuffer;
     _SentenceSplitter:TAIStringTokenizer;
   public
     Constructor Create(pALiceBuffer:TIMBuffer);
     Destructor Destroy;override;
   protected
     Procedure Execute; override;
  end;

implementation
uses f_AIPatternMatcher,f_IMContactInfo,f_IMTransmitPacket,f_IMConsts,f_AITemplateProcessor,f_AIVariables,
     f_RoYaDefines, f_AIAIMLLoader;

{ TIMAI }
constructor TIMAlice.Create(pAliceBuffer:TIMBuffer);
begin
  inherited Create(false);
  FreeOnTerminate:=true;
  fAliceBuffer:=pALiceBuffer;
  BotLoader:=TBotLoader.Create;
  Memory:=TAIMemory.create;
  Preprocessor:=TAISimpleSubstituter.create;
  AIMLLoader:=TAIMLLoader.Create(CurrentPath);
  PatternMatcher:=TPatternMatcher.Create;
  TemplateProcessor:=TTemplateProcessor.Create;
  BotLoader.load(CurrentPath+coPathAIStartupXml);
  _SentenceSplitter:=TAIStringTokenizer.Create(SentenceSplitterChars);
end;

destructor TIMAlice.Destroy;
begin
  _SentenceSplitter.Free;
  TemplateProcessor.Free;
  PatternMatcher.Free;
  AIMLLoader.Free;
  Preprocessor.Free;
  Memory.Free;
  BotLoader.Free;
  fAliceBuffer.Free;
  inherited;
end;

procedure TIMAlice.Execute;
var
  vTransmitPacket:TIMTransmitPacket;
  vOutBuffer:TIMBuffer;
  vInput:String;
  vReply:string;
  vCount:Integer;
  vMatch:TMatch;
begin
  inherited;
  while not Terminated do
  begin
    sleep(1);
    if fAliceBuffer.Count=0 then
      Continue;
    vTransmitPacket:=fAliceBuffer.POP;
    vInput:=vTransmitPacket.ContactInfo.In_ListParam.Text;
    if (Trim(vInput)<>'') and (pos('/',vInput)<>1) then
     begin
       Memory.Load(vTransmitPacket.ContactInfo.AliceInfo);

       Memory.setVar('input',vInput);
       vInput:=Trim(ConvertWS(Preprocessor.process(' '+vInput+' '),true));
       _SentenceSplitter.SetDelimiter(SentenceSplitterChars);
       _SentenceSplitter.Tokenize(vInput);

       for vCount:=0 to _SentenceSplitter._count-1 do
        begin
          vInput:=Trim(_SentenceSplitter._tokens[vCount]);
          vMatch:=PatternMatcher.MatchInput(vInput);
          vReply:=TemplateProcessor.Process(vMatch);
          vMatch.free;
        end;

       vReply:=PreProcessor.process(vReply);
       _SentenceSplitter.SetDelimiter(SentenceSplitterChars);
       _SentenceSplitter.Tokenize(vReply);
       Memory.setVar('that',_SentenceSplitter.GetLast);
       vTransmitPacket.ContactInfo.Out_InstantMessage.Add('<b>Alice :</b>'+vReply);
     end;
     vOutBuffer:=(vTransmitPacket.Buffer as TIMBuffer);
     vOutBuffer.Push(vTransmitPacket);
  end;
end;

end.
