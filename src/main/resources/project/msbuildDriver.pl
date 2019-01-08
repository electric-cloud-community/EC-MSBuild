use strict;
use warnings;
$|=1;
use ElectricCommander;

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

my $ec = new ElectricCommander();
$ec->abortOnError(0);

my $msbuild = $ec->getProperty("/myCall/msbuild")-> findvalue("//value")->value();
my $WorkingDirectory = $ec->getProperty("/myCall/workingDirectory")-> findvalue("//value")->value();
my $Target = $ec->getProperty("target")-> findvalue("//value")->value();
my $LoggerOption = $ec->getProperty("loggerOption")-> findvalue("//value")->value();
my $ProjectSolution = $ec->getProperty("projectSolution")-> findvalue("//value")->value();
my $AdditionalOptions = $ec->getProperty("additionalOptions")-> findvalue("//value")->value();
my $MsbuildProperty = $ec->getProperty("msbuildProperty")-> findvalue("//value")->value();
my $postpLine = $ec->getProperty("postpLine")-> findvalue("//value")->value();

#----------------------------------------------------------------------------
# main - contains the whole process to be done by the plugin, it builds 
#        the command line, sets the properties and the working directory
#
# Arguments:
#   -none
#
# Returns:
#   -nothing
#
#----------------------------------------------------------------------------
sub main() {
    
    # create args array
    my @args = ();
    my %props;	

    # if target: add to command string
    if($Target && $Target ne "") {
        push(@args, "/target:$Target");
    }

    # if msbuildPropertyName, msbuildPropertyValue: add to command string
    if($MsbuildProperty && $MsbuildProperty ne "") {
        push(@args, "/property:$MsbuildProperty");
    }
    
    # if gLoggerOption: add to command string
    if($LoggerOption && $LoggerOption ne "") {
        push(@args,"/logger:FileLogger,Microsoft.Build.Engine;logfile=$LoggerOption") 
    }
    
    # if gProjectSolution: add to command string
    if($ProjectSolution && $ProjectSolution ne "") {
        foreach my $gProjectSolution (split(' ', "$ProjectSolution")) {
            push(@args, $gProjectSolution);
        }
    }
    
    #Additional options can be added to the jtest command
    if($AdditionalOptions  && $AdditionalOptions  ne "") {
        push(@args, $AdditionalOptions);
    }
    
    if($postpLine && $postpLine ne "") {
        $props{"postpLine"} = $postpLine;
    } else {
        $props{"postpLine"} = "postp --loadProperty /myProject/postp_matchers";
    }
    
    $props{"msbuildWorkingDir"} = $WorkingDirectory;
    $props{"msbuildCommandLine"} = createMSBuildCommandLine($msbuild, \@args);
    setProperties($ec, \%props);
}

#----------------------------------------------------------------------
# createMSBuildCommandLine - creates the command line for the invocation
# of the program to be executed.
#
# Arguments:
#   -msbuild: path to MSBuild executable
#   -arr: array containing the command name and the arguments entered by 
#         the user in the UI
#
# Returns:
#   -the command line to be executed by the plugin
#
#---------------------------------------------------------------------

sub createMSBuildCommandLine {

    my ($msbuild, $arr) = @_;

    my $command = "\"$msbuild\" /nologo";

    foreach my $elem (@$arr) {
        $command .= " $elem";
    }
    
    return $command;
}

#------------------------------------------------------------------------
# setProperties - set a group of properties into the Electric Commander
#
# Arguments:
#   -propHash: hash containing the ID and the value of the properties 
#              to be written into the Electric Commander
#
# Returns:
#   -nothing
#
#----------------------------------------------------------------------

sub setProperties {
	
    my ($ec, $propHash) = @_;

    foreach my $key (keys % $propHash) {
        $ec->setProperty("/myCall/$key", $propHash->{$key});
    }
}

main();
