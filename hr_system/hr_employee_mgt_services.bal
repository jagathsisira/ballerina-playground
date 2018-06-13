import ballerina/http;
import ballerina/log;

type InputData {
    Employee employee;
    int recordId;
    string createdDate;
    string lastUpdated;
};

type Employee {
    string name;
    int age;
    string city;
    string employeeId;
    string departmentId;
};

endpoint http:Listener EmployeeMgtServiceListener {
    port:9023
};

@http:ServiceConfig {
    basePath: "/hr"
}
service<http:Service> hrEmployeeManagementService bind EmployeeMgtServiceListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employees"
    }
    addEmployee(endpoint caller, http:Request addEmployeeReq) {
        InputData inputData;
        Employee employee;
        http:Response addEmployeeResponse = new;
        json responseJson = {};

        //Extract Employee Information from the JSON request
        var payloadJson = check addEmployeeReq.getJsonPayload();
        inputData = check <InputData>payloadJson;
        employee = inputData.employee;

        log:printDebug("Employee details received : " + payloadJson.toString());

        //Validate information, if validation failed, send HTTP 400 response
        if(employee != null && employee.name != null && employee.age > 0 && employee.city != null) {
            log:printDebug("Employee data validation successful ");
            responseJson.status = "Success";
            responseJson.employeeId = employee.employeeId;
            responseJson.message = "Employee information successfull added to the system";

            addEmployeeResponse.setJsonPayload(responseJson);
            addEmployeeResponse.statusCode = 200;
        } else {
            log:printError("Employee data validation error occured");
            responseJson.status = "Error";
            responseJson.message = "Incomplete information in Employee Details";

            addEmployeeResponse.setJsonPayload(responseJson);
            addEmployeeResponse.statusCode = 400;
        }

        caller->respond(addEmployeeResponse) but {
            error e => log:printError("Error sending response from addEmployee service : ", err = e)
        };
    }
}
