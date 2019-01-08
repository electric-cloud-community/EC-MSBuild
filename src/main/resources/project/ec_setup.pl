
# Data that drives the create step picker registration for this plugin.
my %runMSBuild = (
    label       => "MSBuild - Run Build",
    procedure   => "runMSBuild",
    description => "Integrates MSBuild Build framework into Electric Commander",
    category    => "Build"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/MSBuild - Run Build");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/MSBuild");

@::createStepPickerSteps = (\%runMSBuild);

if ($upgradeAction eq 'upgrade') {
    # When upgrading from older versions, find steps that call plugins procedure
    # and remove extra outdated parameters (msbuildPropertyName, msbuildPropertyValue) 
    my @filterList = (
     { 'propertyName' => 'subprocedure',
        'operator' => 'equals',
        'operand1' => 'runMSBuild' },
     { 'propertyName' => 'subproject',
         'operator' => 'equals',
         'operand1' => '/plugins/@PLUGIN_KEY@/project' });
    my $result = $commander->findObjects('procedureStep', {
        filter => [ { operator => 'and', filter => \@filterList} ]
    });

    for my $procedureStep ($result->findnodes('//step')) {
        my $projectName = $procedureStep->find('projectName')->string_value;
        my $procedureName = $procedureStep->find('procedureName')->string_value;
        my $stepName = $procedureStep->find('stepName')->string_value;

        $commander->deleteActualParameter($projectName, $procedureName, $stepName, 'msbuildPropertyName');
        $commander->deleteActualParameter($projectName, $procedureName, $stepName, 'msbuildPropertyValue');
    }
}
