import ballerina/http;
import ballerina/log;

endpoint http:Listener DataMigrationListener {
    port:9022
};

@http:ServiceConfig {
    basePath: "/data-migration"
}
service<http:Service> dataMigrationService bind DataMigrationListener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employees/{employeeId}"
    }
    migrateEmployee(endpoint caller, http:Request migrationRequest, string employeeId) {
        http:Response callerResponse = new;

        //Get new Employee ID from Data Migration Service
        json responseJson = getNewEmployeeInfo(employeeId);

        //If the response is not null, it is a successfull response, error otherwise
        if(responseJson != null){
            callerResponse.setJsonPayload(responseJson);
        } else {
            callerResponse.statusCode = 404;
        }

        caller->respond(callerResponse)  but {
            error e => log:printError("Error sending response back ", err = e)
        };
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/departments/{departmentId}"
    }
    migrateDepartment(endpoint caller, http:Request migrationRequest, string departmentId) {
        http:Response callerResponse = new;

        //Get new Department ID from Data Migration Service
        json responseJson = getNewDepartmentInfo(departmentId);

        //If the response is not null, it is a successfull response, error otherwise
        if(responseJson != null){
            callerResponse.setJsonPayload(responseJson);
        } else {
            callerResponse.statusCode = 404;
        }

        caller->respond(callerResponse) but {
            error e => log:printError("Error sending response back ", err = e)
        };
    }
}
