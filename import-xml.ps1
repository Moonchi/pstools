<#
.Synopsis
   Reading an XML file
.DESCRIPTION
   Reads a xml-file. The namespace will automatically read out of the file.
   Returns a ps-xml-object.

   The namespace manager is saved in a global variable
   Variable names without parameters:
   variable: xml1
   ns-manager: nsmgr
   ns-prefix: ns

   You can directly work with the $xml1 variable.

.EXAMPLE
   Import-Xml -Path $path
.EXAMPLE
   Import-Xml -Path $path -XmlVariable "xmlName" -NamespacePrefix "myprefix"
.EXAMPLE
   Get-ChildItem -Path $path *.xml | Import-Xml
#>
function Import-Xml
{
    Param
    (
        [String]$Path,
        [String]$NamespacePrefix = "ns",
        [String]$XmlVariableName = "xml",
        [String]$NamespaceManager = "nsmgr",
        [String]$Namespace,
        [Parameter(ValueFromPipelineByPropertyName=$true)][String]$FullName
    )

    Begin
    {
        $counter = 0;
    }

    Process
    {
        #add counter variable names
        if($counter -eq 0)
        {
            $xmlGenericVariableName = $XmlVariableName;
            $genericNamespacePrefix = $NamespacePrefix;
            $genericNamespaceManager = $NamespaceManager;


        }
        else
        {
            $xmlGenericVariableName = $XmlVariableName + $counter;
            $genericNamespacePrefix = $NamespacePrefix + $counter;
            $genericNamespaceManager = $NamespaceManager + $counter;
        }

        #initialize variables
        if(-not (Test-Path "Variable:\$xmlGenericVariableName") -and -not (Test-Path "Variable:\$genericNamespacePrefix") -and -not (Test-Path "Variable:\$genericNamespaceManager"))
        {
            #without counter if variables doesn't exist
            
            #xml
            New-Variable -Name $xmlGenericVariableName -Visibility Public -Scope global -Force
            [xml](Get-Variable -Name $xmlGenericVariableName).Value = New-Object System.Xml.XmlDocument;

            #create namespace manager
            New-Variable -Name $genericNamespaceManager -Visibility Public -Scope global -Force 
            [System.Xml.XmlNamespaceManager](Get-Variable -Name $genericNamespaceManager).Value = New-Object System.Xml.XmlNamespaceManager -ArgumentList (((Get-Variable -Name $xmlGenericVariableName).Value).NameTable)
        }
        else
        {
            #same with counter if variables exist
            $counter++;
            #xml
            New-Variable -Name $xmlGenericVariableName -Visibility Public -Scope global -Force
            [xml](Get-Variable -Name $xmlGenericVariableName).Value = New-Object System.Xml.XmlDocument;

            #create namespace manager
            New-Variable -Name $genericNamespaceManager -Visibility Public -Scope global -Force 
            [System.Xml.XmlNamespaceManager](Get-Variable -Name $genericNamespaceManager).Value = New-Object System.Xml.XmlNamespaceManager -ArgumentList (((Get-Variable -Name $xmlGenericVariableName).Value).NameTable)
        }
        
        #validate input
        if($FullName)
        {
            $Path = $FullName;
        }
        elseif(-not (Test-Path $Path))
        {
            Write-Host $Path "is not a valid path"
            return;
        }
        elseif(-not $FullName -and -not $Path)
        {
            Write-Host "No input!"
            return;
        }
        else
        {
           $(Get-Variable -Name $xmlGenericVariableName).Value.Load($Path)    
        }
        
        #fill namespace manager
        if(-not $Namespace)
        {
            (Get-Variable -Name $genericNamespaceManager).Value.AddNamespace($genericNamespacePrefix, $xml.DocumentElement.NamespaceURI)
        }
        else
        {
            (Get-Variable -Name $genericNamespaceManager).Value.AddNamespace($genericNamespacePrefix, $Namespace)
        }
        
        #output
        "`n{0}`nvariable:`t{1}`nns-manager:`t{2}`nns-prefix:`t{3}" -f $Path,$xmlGenericVariableName,$genericNamespaceManager,$genericNamespacePrefix        
    }
}