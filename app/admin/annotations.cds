using {LeaveService} from '../../srv/leave-service';
using from '@sap/cds/common';


////////////////////////////////////////////////////////////////////////////
//
//	Employee List Page
//
annotate LeaveService.ManageEmployees with @(
    UI                                : {LineItem: [
        {
            $Type: 'UI.DataField',
            Value: empID,
        },
        {
            $Type                : 'UI.DataField',
            Value                : name,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            }
        },
        {
            $Type                : 'UI.DataField',
            Value                : jobTitle,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            }
        },
        {
            $Type                : 'UI.DataField',
            Value                : department,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            }
        },
        {
            $Type                : 'UI.DataField',
            Value                : email,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '13rem',
            }
        },
        {
            $Type                : 'UI.DataField',
            Value                : phoneNumber,
            ![@HTML5.CssDefaults]: {
                $Type: 'HTML5.CssDefaultsType',
                width: '10rem',
            }
        },
    ]},
    UI.FieldGroup #PersonalInformation: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type                  : 'UI.DataField',
                Value                  : name,
                ![@Common.FieldControl]: {$edmJson: {$If: [
                    {$Eq: [
                        {$Path: 'HasActiveEntity'},
                        true
                    ]},
                    1,
                    3
                ]}} //(3=editable, 1= not editable)
            },
            {
                $Type: 'UI.DataField',
                Value: email,
            },
            {
                $Type: 'UI.DataField',
                Value: phoneNumber,
            },
            {
                $Type: 'UI.DataField',
                Value: jobTitle,
            },
            {
                $Type: 'UI.DataField',
                Value: department,
            },
            {
                $Type: 'UI.DataField',
                Value: location,
            },
            {
                $Type: 'UI.DataField',
                Value: country,
            },
        ],
    },
    UI.FieldGroup #SickLeave          : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type                  : 'UI.DataField',
                Value                  : sickLeaveAvailable,
                ![@Common.FieldControl]: {$edmJson: {$If: [
                    {$Eq: [
                        {$Path: 'HasActiveEntity'},
                        true
                    ]},
                    1,
                    3
                ]}} //(3=editable, 1= not editable)
            },
            {
                $Type: 'UI.DataField',
                Value: sickLeaveApplied,
            },
            {
                $Type: 'UI.DataField',
                Value: sickLeaveAvailed,
            }
        ],
    },
    UI.FieldGroup #CasualLeave        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type                  : 'UI.DataField',
                Value                  : casualLeaveAvailable,
                ![@Common.FieldControl]: {$edmJson: {$If: [
                    {$Eq: [
                        {$Path: 'HasActiveEntity'},
                        true
                    ]},
                    1,
                    3
                ]}} //(3=editable, 1= not editable)
            },
            {
                $Type: 'UI.DataField',
                Value: casualLeaveApplied,
            },
            {
                $Type: 'UI.DataField',
                Value: casualLeaveAvailed,
            }
        ],
    },
    UI.FieldGroup #EarnedLeave        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type                  : 'UI.DataField',
                Value                  : earnedLeaveAvailable,
                ![@Common.FieldControl]: {$edmJson: {$If: [
                    {$Eq: [
                        {$Path: 'HasActiveEntity'},
                        true
                    ]},
                    1,
                    3
                ]}} //(3=editable, 1= not editable)
            },
            {
                $Type: 'UI.DataField',
                Value: earnedLeaveApplied,
            },
            {
                $Type: 'UI.DataField',
                Value: earnedLeaveAvailed,
            }
        ],
    },
    Communication.Contact #contact2   : {
        $Type: 'Communication.ContactType',
        fn   : name,
        tel  : [{
            $Type: 'Communication.PhoneNumberType',
            type : #work,
            uri  : phoneNumber,
        }, ],
        email: [{
            $Type  : 'Communication.EmailAddressType',
            type   : #work,
            address: email,
        }, ],
        adr  : [{
            $Type  : 'Communication.AddressType',
            type   : #work,
            country: country,
            region : location,
        }, ],
        title: jobTitle,
        org  : department,
    },
);

//////////////////////////////////////////////////////////////////////////

// Employee Object Page

annotate LeaveService.ManageEmployees with @(UI: {
    HeaderInfo        : {
        TypeName      : 'Employee Details',
        TypeNamePlural: 'Employees',
        TypeImageUrl  : 'sap-icon://add-employee',
        Title         : {
            $Type: 'UI.DataField',
            Value: name,
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: jobTitle,
        },
    },
    HeaderFacets      : [{
        $Type : 'UI.ReferenceFacet',
        // Label : '{i18n>Description}',
        Target: '@UI.FieldGroup#Header'
    }, ],
    Facets            : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Personal Information',
            ID    : 'PersonalInformation',
            Target: '@UI.FieldGroup#PersonalInformation',
        },

        {
            $Type : 'UI.CollectionFacet',
            Label : 'Leave Summary',
            ID    : 'LeaveBalanceInformation',
            Facets: [
                {
                    //column 1
                    $Type : 'UI.ReferenceFacet',
                    Target: '@UI.FieldGroup#SickLeave',
                    Label : 'Sick Leave'
                },
                {
                    //Column 2
                    $Type : 'UI.ReferenceFacet',
                    Target: '@UI.FieldGroup#CasualLeave',
                    Label : 'Causal Leave'
                },
                {
                    //Cloumn 3
                    $Type : 'UI.ReferenceFacet',
                    Target: '@UI.FieldGroup#EarnedLeave',
                    Label : 'Earned Leave'
                },
            ]
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Approvals',
            ID    : 'Approvals',
            Target: 'leaves/@UI.LineItem#Approvals',
        },

    ],
    FieldGroup #Header: {Data: [
        {
            $Type : 'UI.DataFieldForAnnotation',
            Target: '@Communication.Contact#contact2',
            Label : 'Name',
        },
        {
            $Type: 'UI.DataField',
            Label: 'Created By',
            Value: 'Admin',
        },
        {
            $Type: 'UI.DataField',
            Value: createdAt,
        },
    ]},
});

annotate LeaveService.ManageEmployees with {
    name @(
           // UI.MultiLineText   : true,
         Common.FieldControl: #Mandatory,
    )
};

annotate LeaveService.ManageEmployees with {
    jobTitle @(
        Common                         : {ValueList: {
            Label         : 'Job Title',
            CollectionPath: 'JobTitles',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: jobTitle,
                    ValueListProperty: 'jobTitle'
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: department,
                    ValueListProperty: 'department'
                }
            ]
        }},
        Common.ValueListWithFixedValues: true
    );
}

// annotate LeaveService.ManageEmployees with {
//     country @(
//         Common                         : {
//             Text     : country.name, // TextArrangement: #TextOnly,
//             ValueList: {
//                 Label         : 'Country',
//                 CollectionPath: 'Countries',
//                 Parameters    : [
//                     {
//                         $Type            : 'Common.ValueListParameterInOut',
//                         LocalDataProperty: country_code,
//                         ValueListProperty: 'code'
//                     },
//                     {
//                         $Type            : 'Common.ValueListParameterDisplayOnly',
//                         ValueListProperty: 'name'
//                     }
//                 ]
//             }
//         },
//         Common.ValueListWithFixedValues: true
//     );
// }

annotate LeaveService.Leaves with @(UI.LineItem #Approvals: [
    {
        $Type: 'UI.DataField',
        Value: type,
    },
    {
        $Type                : 'UI.DataField',
        Value                : status,
        Criticality          : criticality,
        ![@HTML5.CssDefaults]: {
            $Type: 'HTML5.CssDefaultsType',
            width: '10rem',
        }
    },
    {
        $Type: 'UI.DataField',
        Value: startDate,
    },
    {
        $Type: 'UI.DataField',
        Value: endDate,
    },
    {
        $Type: 'UI.DataField',
        Value: days,
    },
    {
        $Type: 'UI.DataField',
        Value: reason,
    },
    {
        $Type: 'UI.DataField',
        Value: appliedDate,
    },
    {
        $Type: 'UI.DataField',
        Value: approverComment,
    },
    {
        $Type            : 'UI.DataFieldForAction',
        Action           : 'LeaveService.approveLeave',
        Label            : 'Approve',
        Inline           : true,
        Criticality      : #Positive,
        ![@UI.Importance]: #High,
    // ![@UI.Hidden]    : {$edmJson: {$Eq: [
    //     {$Path: 'approveRejectHidden'},
    //     true
    // ]}}
    },
    {
        $Type            : 'UI.DataFieldForAction',
        Action           : 'LeaveService.rejectLeave',
        Label            : 'Reject',
        Inline           : true,
        Criticality      : #Negative,
        ![@UI.Importance]: #High,
    // ![@UI.Hidden]    : {$edmJson: {$Eq: [
    //     {$Path: 'approveRejectHidden'},
    //     true
    // ]}}
    },
], );

annotate LeaveService.ManageEmployees with {
    department         @Common.FieldControl: #ReadOnly;
    sickLeaveApplied   @Common.FieldControl: #ReadOnly;
    sickLeaveAvailed   @Common.FieldControl: #ReadOnly;
    casualLeaveApplied @Common.FieldControl: #ReadOnly;
    casualLeaveAvailed @Common.FieldControl: #ReadOnly;
    earnedLeaveApplied @Common.FieldControl: #ReadOnly;
    earnedLeaveAvailed @Common.FieldControl: #ReadOnly;
};
