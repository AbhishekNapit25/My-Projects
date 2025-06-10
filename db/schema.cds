using {
    cuid,
    managed
} from '@sap/cds/common';

namespace leave;

entity Employees : cuid, managed {
    empID                : Integer         @title: '{i18n>empID}';
    name                 : String          @title: '{i18n>name}';
    email                : String          @title: '{i18n>email}';
    phoneNumber          : String          @title: '{i18n>phoneNumber}';
    location                : String          @title: '{i18n>location}';
    country              : String          @title: '{i18n>country}';
    jobTitle             : String          @title: '{i18n>jobTitle}';
    department           : String          @title: '{i18n>department}';
    sickLeaveAvailable   : Int16           @title: '{i18n>sickLeaveAvailable}';
    sickLeaveApplied     : Int16 default 0 @title: '{i18n>sickLeaveApplied}';
    sickLeaveAvailed     : Int16 default 0 @title: '{i18n>sickLeaveAvailed}';
    casualLeaveAvailable : Int16           @title: '{i18n>casualLeaveAvailable}';
    casualLeaveApplied   : Int16 default 0 @title: '{i18n>casualLeaveApplied}';
    casualLeaveAvailed   : Int16 default 0 @title: '{i18n>casualLeaveAvailed}';
    earnedLeaveAvailable : Int16           @title: '{i18n>earnedLeaveAvailable}';
    earnedLeaveApplied   : Int16 default 0 @title: '{i18n>earnedLeaveApplied}';
    earnedLeaveAvailed   : Int16 default 0 @title: '{i18n>earnedLeaveAvailed}';
    leaves               : Composition of many Leaves
                               on leaves.employee = $self;
}

entity Leaves : cuid {
    type                 : String   @title: '{i18n>type}';
    status               : String   @title: '{i18n>status}';
    startDate            : Date     @title: '{i18n>startDate}';
    endDate              : Date     @title: '{i18n>endDate}';
    reason               : String   @title: '{i18n>reason}';
    days                 : Int16    @title: '{i18n>days}';
    appliedDate          : DateTime @title: '{i18n>appliedDate}';
    criticality          : Integer default 2;
    approverComment      : String   @title: '{i18n>approverComment}';
    approveRejectEnabled : Boolean default true;
    employee             : Association to Employees;
}

entity LeaveTypes {
    key type : String;
}

entity JobTitles {
    key jobTitle   : String;
        department : String;
}
