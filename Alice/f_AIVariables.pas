unit f_AIVariables;

interface
uses classes,f_AIPatternMatcher;
type
  TAIMemory=class
    vars:TStringList;
    props:TStringList;
    bot_ID:string;
    //Match:TMatch;
    constructor create;
    destructor Destroy; override;
    procedure setVar(name,value:string); overload; virtual;
    procedure setVar(name:string;index:integer;value:string); overload; virtual;
    function getVar(name:string):string; overload; virtual;
    function getVar(name:string;index:integer):string; overload; virtual;
    procedure ClearVars;


    function getProp(name:string):string;
    procedure setProp(name,value:string);

    Procedure Save;
    Procedure Load;overload;
    Procedure Load(Value:TStringlist);overload;//Added Ali Mashatan 2008/08/24
  end;
var Memory:TAIMemory;
implementation
uses sysutils;
  constructor TAIMemory.Create;
    begin
      inherited Create;
      //vars:=TStringList.Create;
      //vars.Duplicates:=dupError;
      //vars.Sorted:=False;
      Props:=TStringList.Create;
      Props.Duplicates:=dupError;
      Props.Sorted:=False;
    end;
  destructor TAIMemory.Destroy;
    begin
      //vars.Free;
      Props.Free;
      inherited Destroy;
    end;
  procedure TAIMemory.setVar(name,value:string);
    begin
      setVar(name,0,value);
    end;
  procedure TAIMemory.setVar(name:string;index:integer;value:string);
    begin
      name:=name+'['+inttostr(index)+']';
      vars.values[name]:=value;
    end;

  function TAIMemory.getVar(name:string):string;
    begin
      result:=getVar(name,0);
    end;
  function TAIMemory.getVar(name:string;index:integer):string;
    begin
      name:=name+'['+inttostr(index)+']';
      result:=vars.Values[name];
    end;
  procedure TAIMemory.setprop(name,value:string);
    begin
      props.values[name]:=value;
    end;
  function TAIMemory.getProp(name:string):string;
    begin
      result:=props.Values[name];
    end;
  procedure TAIMemory.ClearVars;
    begin
      vars.Clear;
    end;

  Procedure TAIMemory.Save;
    var filename:string;
    begin
      filename:=bot_id+'.variables';
      //Log.Log('variables','Saving variables for the bot '+bot_id); // Commented by Ali Mashatan 2008/08/24
      try
        Vars.SaveToFile(filename);
      except
       // Log.Log('variables','Error while saving variables'); // Commented by Ali Mashatan 2008/08/24
      end;
    end;

  Procedure TAIMemory.Load;
    var
      filename:string;
    begin
      filename:=bot_id+'.variables';
      if fileexists(filename) then begin
        //Log.Log('variables','Loading variables for the bot '+bot_id); // Commented by Ali Mashatan 2008/08/24
        Vars.LoadFromFile(filename);
      end;
    end;

  Procedure TAIMemory.Load(Value:TStringlist);
    begin
      Vars:=Value;
      vars.Duplicates:=dupError;
      vars.Sorted:=False;
    end;

end.
