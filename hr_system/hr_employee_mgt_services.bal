import ballerina/io;
import ballerina/http;
import ballerina/log;

type EmployeeRecord {
    string name;
    int age;
    string city;
    string employeeId;
    string departmentId;
    string createdDate;
    string lastUpdated;
};

endpoint http:Listener EmployeeMgtServiceListener {
    port:9023
};

@http:ServiceConfig {
    basePath: "/hr/employee-mgt"
}
service<http:Service> hrEmployeeManagementService bind EmployeeMgtServiceListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employee"
    }
    addEmployee(endpoint caller, http:Request addEmployeeReq) {
        http:Response addEmployeeResponse = new;
        EmployeeRecord employeeRecord;
        json responseJson = {};
        var payloadJson = check addEmployeeReq.getJsonPayload();
        employeeRecord = check <EmployeeRecord >payloadJson;

        log:printDebug("Employee details received : " + payloadJson.toString());

        if(employeeRecord.name != null && employeeRecord.age > 0 && employeeRecord.city != null) {
            log:printDebug("Employee data validation successful ");
            responseJson.result = "success";
            responseJson.employeeId = employeeRecord.employeeId;
            responseJson.message = "Employee information successfull added to the system";

            addEmployeeResponse.setJsonPayload(responseJson);
            addEmployeeResponse.statusCode = 200;
        } else {
            log:printError("Employee data validation error occured");
            responseJson.result = "error";
            responseJson.employeeId = employeeRecord.employeeId;
            responseJson.message = "Incomplete information in Employee Details";

            addEmployeeResponse.setJsonPayload(responseJson);
            addEmployeeResponse.statusCode = 400;
        }

        caller->respond(addEmployeeResponse) but {
            error e => log:printError("Error sending response from addEmployee service : ", err = e)
        };
    }
}
