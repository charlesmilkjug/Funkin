package funkin.ui.debug.charting.toolboxes;

import funkin.util.FileUtil;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.events.UIEvent;

using StringTools;

/**
 * Built-in HScript Editor
 * (for now, it's bassically a normal text editor, stay tunned :3)
 */
@:access(funkin.ui.debug.charting.ChartEditorState)
@:build(haxe.ui.ComponentBuilder.build("assets/exclude/data/ui/chart-editor/toolboxes/script-editor.xml"))
class ChartEditorScriptEditor extends ChartEditorBaseToolbox
{
  var curScript:String;
  var curSongName:String;
  var specialChars:Array<String> = ['\'', '.'];

  public function new(chartEditorState2:ChartEditorState)
  {
    super(chartEditorState2);
    curScript = this.scriptText.text;
    initialize();
    this.onDialogClosed = onClose;
    this.savebtn.onClick = onSave;
    this.readbtn.onClick = onRead;
    trace("Script Editor initiated");
  }

  function onClose(event:UIEvent):Void
  {
    chartEditorState.menubarItemToggleToolboxScriptEditor.selected = false;
  }

  function onSave(event:UIEvent):Void
  {
    Dialogs.saveTextFile("Save HScript File", [
      {extension: "hxc", label: "HScript"}], {name: '${curSongName}.hxc', text: scriptText.text}, function(result, path) {
        if (result)
        {
          chartEditorState.success("File saved!", "HScript Saved");
        }
    });
  }

  function onRead(event:UIEvent):Void
  {
    FileUtil.browseForTextFile("Read Script", [
      {extension: "hxc", label: "HScript"}], function(fileinfo) {
        curScript = fileinfo.text;
        curScript = curScript.replace('\t', '    ');
        scriptText.text = curScript;
        trace("Script Read!");
    });
  }

  function initialize():Void
  {
    this.x = 150;
    this.y = 250;

    // refresh();
    fetch(true);
  }

  public override function refresh():Void
  {
    fetch();
    scriptText.text = curScript;
    trace("Script Editor Refreshed!");
  }

  /**
   * fetch the song script name if exist
   * @param load - refresh the Text Area (Optional)
   */
  function fetch(?load:Bool = false):Void
  {
    curSongName = chartEditorState.currentSongName.replace(' ', '');
    for (i in specialChars)
    {
      if (StringTools.contains(curSongName, i)) curSongName = curSongName.replace(i, '');
    }
    trace(curSongName);
    #if sys
    if (FileUtil.doesFileExist(Paths.file('scripts/songs/${curSongName.toLowerCase()}.hxc')))
    {
      curScript = FileUtil.readStringFromPath(Paths.file('scripts/songs/${curSongName.toLowerCase()}.hxc'));
      curScript = curScript.replace('\t', '    ');
      trace("Script found! Loading");
    }
    else
    {
      chartEditorState.error('Failed to Load Script', '${curSongName} Song script doesn\'t exist or is inaccesible\nLOADING DEFAULT SCRIPT');
      curScript = 'class ${curSongName} extends Song {\n\n\n}';
    }
    #else
    chartEditorState.error('Failed to Load Script', 'Script Editor not implemented for this platform');
    curScript = "ERROR: Script Editor not implemented for this platform";
    #end

    if (load)
    {
      scriptText.text = curScript;
    }
  }

  public static function build(chartEditorState:ChartEditorState):ChartEditorScriptEditor
  {
    return new ChartEditorScriptEditor(chartEditorState);
  }
}
