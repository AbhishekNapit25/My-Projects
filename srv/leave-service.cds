
using { leave } from '../db/schema';

service LeaveService {
    @odata.draft.enabled
    entity ManageEmployees as projection on leave.Employees;

            @readonly
            @cds.redirection.target
    entity EmployeesList   as projection on leave.Employees
        actions {
            // Apply Side Effects
            @(
                cds.odata.bindingparameter.name: '_it',
                Common.SideEffects             : {TargetProperties: [
                    '_it/sickLeaveAvailable',
                    '_it/sickLeaveApplied',
                    '_it/sickLeaveAvailed',
                    '_it/leaves/type',
                    '_it/leaves/startDate',
                    '_it/leaves/endDate',
                    '_it/leaves/days',
                    '_it/leaves/reason',
                    '_it/leaves/status',
                    '_it/leaves/appliedDate',
                ]}
            )
            // @Core: {OperationAvailable: _it.approveRejectHidden}
            action applyLeave(leaveType : String @Common: {
                FieldControl            : #Mandatory,
                Label                   : '{i18n>leaveType}',
                ValueListWithFixedValues: true,
                ValueList               : {
                    $Type         : 'Common.ValueListType',
                    CollectionPath: 'LeaveTypes',
                    Label         : '{i18n>leaveType}',
                    Parameters    : [{
                        $Type            : 'Common.ValueListParameterInOut',
                        LocalDataProperty: leaveType,
                        ValueListProperty: 'type'
                    }, ]
                }
            },
                              startDate : Date @Common: {
                FieldControl: #Mandatory,
                Label       : '{i18n>startDate}'
            },
                              endDate : Date @Common: {
                FieldControl: #Mandatory,
                Label       : '{i18n>endDate}'
            },
                              reason : String @Common: {
                FieldControl: #Mandatory,
                Label       : '{i18n>reason}'
            } @UI.MultiLineText : true );
        };

            @readonly
    entity Leaves          as projection on leave.Leaves
        actions {
            // Apply Side Effects
            @(
                cds.odata.bindingparameter.name: '_it',
                Common.SideEffects             : {TargetProperties: [
                    '_it/approveRejectEnabled',
                    '_it/status',
                    '_it/criticality',
                    '_it/reason',
                ]}
            )
            @Core: {OperationAvailable: _it.approveRejectEnabled}
            action approveLeave(comment : String @Common: {Label: '{i18n>comment}'} );

            // Apply Side Effects
            @(
                cds.odata.bindingparameter.name: '_it',
                Common.SideEffects             : {TargetProperties: [
                    '_it/approveRejectEnabled',
                    '_it/status',
                    '_it/criticality',
                    '_it/reason',
                ]}
            )
            @Core: {OperationAvailable: _it.approveRejectEnabled}
            action rejectLeave(comment : String @Common: {Label: '{i18n>comment}'} );

        };

    entity LeaveTypes      as projection on leave.LeaveTypes;
    entity JobTitles       as projection on leave.JobTitles;
}
