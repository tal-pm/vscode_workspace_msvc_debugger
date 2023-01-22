param (
    [Parameter(Mandatory=$true)][string]$SRC_NAME,
    [Parameter(Mandatory=$true)][string]$BIN_NAME,
    [Parameter(Mandatory=$true)][string]$INCLUDE_NAME,
    [Parameter(Mandatory=$true)][string]$RES_NAME
)

$old_path=(Get-Item .).FullName
$project_dir = ($old_path -replace '((?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)(?!.*(?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)).*)|((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)|((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)|((?:[Rr]esource(?:s)?|[Rr]es)(?!.*(?:[Rr]esource(?:s)?|[Rr]es)).*)|((?:[Ll]ibraries|[Ll]ib(?:rary|s)?)(?!.*(?:[Ll]ibraries|[Ll]ib(?:rary|s)?)).*)', '')
cd $project_dir

$source = (((Get-ChildItem -Path $project_dir -Directory | Where-Object {$_.name -match '^((?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)(?!.*(?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)).*)$'}).fullname) -join ' ' 2>&1)
if ($source -notmatch '((?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)(?!.*(?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)).*)') {

    mkdir $SRC_NAME
    Move-Item *.cpp $SRC_NAME
    Move-Item *.c $SRC_NAME
}

$build = (((Get-ChildItem -Path $project_dir -Directory | Where-Object {$_.name -match '^((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)$'}).fullname) -join ' ' 2>&1)
if ($build -notmatch '((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)') {
    mkdir $BIN_NAME
}

$include = (((Get-ChildItem -Path $project_dir -Directory | Where-Object {$_.name -match '^((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)$'}).fullname) -join ' ' 2>&1)
if ($include -notmatch '((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)') {
    mkdir $INCLUDE_NAME
    Move-Item *.h $INCLUDE_NAME
    Move-Item *.hpp $INCLUDE_NAME
}

$resource = (((Get-ChildItem -Path $project_dir -Directory | Where-Object {$_.name -match '^((?:[Rr]esource(?:s)?|[Rr]es)(?!.*(?:[Rr]esource(?:s)?|[Rr]es)).*)$'}).fullname) -join ' ' 2>&1)
if ($resource -notmatch '((?:[Rr]esource(?:s)?|[Rr]es)(?!.*(?:[Rr]esource(?:s)?|[Rr]es)).*)') {
    mkdir $RES_NAME
}