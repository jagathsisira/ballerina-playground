import ballerina/io;
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
        path: "/employee/{employeeId}"
    }
    migrateEmployee(endpoint caller, http:Request migrationRequest, string employeeId) {
        http:Response callerResponse = new;
        json responseJson = getNewEmployeeInfo(employeeId);

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
        path: "/department/{departmentId}"
    }
    migrateDepartment(endpoint caller, http:Request migrationRequest, string departmentId) {
        http:Response callerResponse = new;
        json responseJson = getNewDepartmentInfo(departmentId);

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
