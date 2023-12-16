# MSVC Debugger support for c/c++ with .vscode workspace folder

![](https://img.shields.io/github/stars/tails-pm/vscode_workspace_msvc_debugger) ![](https://img.shields.io/github/forks/tails-pm/vscode_workspace_msvc_debugger) ![](https://img.shields.io/github/v/tag/tails-pm/vscode_workspace_msvc_debugger) ![](https://img.shields.io/github/v/release/tails-pm/vscode_workspace_msvc_debugger) ![](https://img.shields.io/github/issues/tails-pm/vscode_workspace_msvc_debugger)

**Table of Contents**

- [MSVC Debugger support for c/c++ with .vscode workspace folder](#msvc-debugger-support-for-cc-with-vscode-workspace-folder)
- [Project Structure](#project-structure)
  - [Folder name patterns](#folder-name-patterns)
  - [Config file](#config-file)
  - [x64/x86 Compiling](#x64x86-compiling)
- [Additional Information:](#additional-information)
  - [Settings.json](#settingsjson)
  - [MSVC Compiler path](#msvc-compiler-path)
  - [Project dependencies:](#project-dependencies)

# Project Structure

The debugger supports subfolder of the workspace and when a c/c++ file is run via the debugger the debugger will create the following project structure:

📦\<Project Name><br>
┣ 📂Build<br>
┣ 📂Include<br>
┣ 📂Resources<br>
┗ 📂Source<br>

The project can include the additional folder: <br>
📂Libs

## Folder name patterns

> Folder Type `Source Directory`  
> Regex `((?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)(?!.*(?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)).*)`
>
> Folder Type `Include Directory`  
> Regex `((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)`
>
> Folder Type `Build Directory`  
> Regex `((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)`
>
> Folder Type `Resources Directory`  
> Regex `((?:[Rr]esource(?:s)?|[Rr]es)(?!.*(?:[Rr]esource(?:s)?|[Rr]es)).*)`

---

> Optional Folder Type `Library Directory`  
> Regex `((?:[Ll]ibraries|[Ll]ib(?:rary|s)?)(?!.*(?:[Ll]ibraries|[Ll]ib(?:rary|s)?)).*)`

## Config file

You may also create a file named `config.json`:<br>
The file holds the following properties:<br>

- "**ProjectName**" - The name of the project when compiled. Defaults to the currently run file name.
- "**AdditionalIncludes**" - A list of folder directories containing header files to include in compilation process. Defaults to []
- "**AdditionalLibraries**" - A list of folder directories containing libraries to include in the compilation process. Defaults to []
- "**AdditionalDependencies**" - A list of file paths of DLL's to include in the compilation process. Defaults to []
- "**CommandLineFlags**" - A list of additional msvc options and arguments to add to the compilation process. Defaults to []
- "**ExcludeFolders**" - A list of folder names to exclude from the compilation process. Defaults to []
- "**DebugMode**" - A boolean telling to compiler to use /`MDd` Instead of /`MD`. Defaults to true

## x64/x86 Compiling

In the vscode launch settings you may specify the type of compilation from x64 or x86. Default to x64.
<br>
When compiling you may choose one of the following options:

- `Build Project` - compiles only updated file.
- `Rebuild Project` - recompiles the whole project.
- `Run Project` - runs the project without compilation.

<br>

# Additional Information:

## Settings.json

In `settings.json` you may find the following settings:

- `"SourceDirName": "Source",`
- `"BuildDirName": "Build",`
- `"IncludeDirName": "Include",`
- `"ResourceDirName": "Resources",`<br>
  These settings are the default folder names for the project when a folder is missing or not found in the project directory.

## MSVC Compiler path

In `compile_cl.bat` you may change the msvc paths found in the `LOAD_COMPILER` label.

## Project dependencies:

The following vscode extenstion are a required dependency to make the compiler work: <br>

1. `C/C++: `https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools
2. `Tasks Shell Input: `https://marketplace.visualstudio.com/items?itemName=augustocdias.tasks-shell-input
3. `Command Variable: `https://marketplace.visualstudio.com/items?itemName=rioj7.command-variable
