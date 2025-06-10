using {LeaveService} from '../../srv/leave-service';
using from '@sap/cds/common';


////////////////////////////////////////////////////////////////////////////
//
//	Employee List Page
//
annotate LeaveService.EmployeesList with @(
    UI                                : {LineItem: [
        {
            $Type: 'UI.DataField',
            Value: empID,
        },
        {
            $Type: 'UI.DataField',
            Value: name,
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
                width: '10rem',
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
                $Type: 'UI.DataField',
                Value: name,
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
                Value: country,
                Label: 'Country',
            },
            {
                $Type: 'UI.DataField',
                Value: jobTitle,
            },
            {
                $Type: 'UI.DataField',
                Value: department,
            },
        ],
    },
    UI.FieldGroup #SickLeave          : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: sickLeaveAvailable,
            },
            {
                $Type : 'UI.DataField',
                Value : sickLeaveApplied,
            },
            {
                $Type: 'UI.DataField',
                Value: sickLeaveAvailed,
            },
        ],
    },
    UI.FieldGroup #CasualLeave        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: casualLeaveAvailable,
            },
            {
                $Type : 'UI.DataField',
                Value : casualLeaveApplied,
            },
            {
                $Type: 'UI.DataField',
                Value: casualLeaveAvailed,
            },
        ],
    },
    UI.FieldGroup #EarnedLeave        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: earnedLeaveAvailable,
            },
            {
                $Type : 'UI.DataField',
                Value : earnedLeaveApplied,
            },
            {
                $Type: 'UI.DataField',
                Value: earnedLeaveAvailed,
            },
        ],
    },
    UI.FieldGroup #Empty        : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: '',
            },
            // {
            //     $Type : 'UI.DataField',
            //     Value : earnedLeaveApplied,
            // },
            // {
            //     $Type: 'UI.DataField',
            //     Value: earnedLeaveAvailed,
            // },
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
    UI.Identification                 : [
        {
            $Type: 'UI.DataField',
            Value: name,
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'LeaveService.applyLeave',
            Label : 'Apply Leave',
        },
    ],
    UI.SelectionFields                : [
        jobTitle,
        name,
    ],
    UI.SelectionPresentationVariant #tableView : {
        $Type : 'UI.SelectionPresentationVariantType',
        PresentationVariant : {
            $Type : 'UI.PresentationVariantType',
            Visualizations : [
                '@UI.LineItem',
            ],
        },
        SelectionVariant : {
            $Type : 'UI.SelectionVariantType',
            SelectOptions : [
            ],
        },
        Text : 'Table View',
    },
);

//////////////////////////////////////////////////////////////////////////

// Employee Object Page

annotate LeaveService.EmployeesList with @(UI: {
    HeaderInfo        : {
        TypeName      : 'Leave Request',
        TypeNamePlural: 'Leave Requests',
        TypeImageUrl  : 'sap-icon://employee',
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
                {
                    //Cloumn 3
                    $Type : 'UI.ReferenceFacet',
                    Target: '@UI.FieldGroup#Empty',
                    // Label : 'Earned Leave'
                },
            ]
        },
        // {
        //     $Type : 'UI.ReferenceFacet',
        //     Label : 'Leave Balance Information',
        //     ID : 'LeaveBalanceInformation',
        //     Target : '@UI.FieldGroup#LeaveBalanceInformation',
        // },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Request History',
            ID    : 'RequestHistory',
            Target: 'leaves/@UI.LineItem#RequestHistory',
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

annotate LeaveService.EmployeesList with {
    name @(
           // UI.MultiLineText : true,
         Common.FieldControl: #Mandatory,
    )
};

// annotate LeaveService.Countries with {
//     code @Common.Text: {
//         $value                : name,
//         ![@UI.TextArrangement]: #TextFirst,
//     }
// };

// annotate LeaveService.EmployeesList with {
//     country @(
//         Common.ValueList               : {
//             $Type         : 'Common.ValueListType',
//             CollectionPath: 'Countries',
//             Parameters    : [{
//                 $Type            : 'Common.ValueListParameterInOut',
//                 LocalDataProperty: country_code,
//                 ValueListProperty: 'code',
//             }, ],
//             Label         : 'Country',
//         },
//         Common.ValueListWithFixedValues: true
//     )
// };

annotate LeaveService.Leaves with @(
    UI.LineItem #RequestHistory  : [
        {
            $Type: 'UI.DataField',
            Value: type,
        },
        {
            $Type: 'UI.DataField',
            Value: status,
            Criticality: criticality,
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
    ],
);
