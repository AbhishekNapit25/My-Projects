sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'empleaverequest/test/integration/FirstJourney',
		'empleaverequest/test/integration/pages/EmployeesList',
		'empleaverequest/test/integration/pages/EmployeesObjectPage',
		'empleaverequest/test/integration/pages/LeavesObjectPage'
    ],
    function(JourneyRunner, opaJourney, EmployeesList, EmployeesObjectPage, LeavesObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('empleaverequest') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheEmployeesList: EmployeesList,
					onTheEmployeesObjectPage: EmployeesObjectPage,
					onTheLeavesObjectPage: LeavesObjectPage
                }
            },
            opaJourney.run
        );
    }
);