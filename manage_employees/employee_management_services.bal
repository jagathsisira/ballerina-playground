import ballerina/http;
import ballerina/log;

type EmployeeInfo {
    string name;
    int age;
    string city;
    string employee_id;
    string department_id;
    int record_id;
    string created_date;
    string last_updated;
};

endpoint http:Listener EmployeeMgtServiceListener {
    port:9024
};

//Endpoint for HR system
endpoint http:Client hrEP {
    url: "http://localhost:9023/hr/employee-mgt"
};

//Endpoint for Data Migration Services
endpoint http:Client dataMigrationEP {
    url: "http://localhost:9022/data-migration"
};

@http:ServiceConfig {
    basePath: "/"
}
service<http:Service> manageEmployee bind EmployeeMgtServiceListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/employee"
    }
    addEmployee(endpoint caller, http:Request addEmployeeRequest) {
        EmployeeInfo employeeInfo;
        http:Response manageEmployeeResponse = new;
        http:Request hrSystemRequest = new;
        json responseJson = {};
        string employeeId;
        string newEmployeeId;
        string departmentId;
        string newDepartmentId;

        //Process request JSON payload and extract values
        var payloadJson = check addEmployeeRequest.getJsonPayload();
        log:printDebug("Employee information received : " + payloadJson.toString());

        employeeInfo = check <EmployeeInfo>payloadJson;
        employeeId = employeeInfo.employee_id;
        departmentId = employeeInfo.department_id;

        //Employee Migration Service Invocation
        var employeeMigrationResponse = dataMigrationEP->get("/employee/201");

        match employeeMigrationResponse {

            http:Response res => {
                if(res.statusCode == 200){
                    //Extract new Employee ID
                    json employeeMigrationPayload = check res.getJsonPayload();
                    newEmployeeId = employeeMigrationPayload.translateResponse.targetId.toString();
                    log:printDebug("Employee ID Migration : Old - " + employeeId + " Migrated - " + newEmployeeId);
                } else {
                    json errorResponse = {};
                    errorResponse.status = "Error";
                    errorResponse.message = "Error occured while migrating Employee ID - No matching ID found";

                    manageEmployeeResponse.statusCode = 500;
                    manageEmployeeResponse.setJsonPayload(errorResponse);

                    caller->respond(manageEmployeeResponse) but { error e =>
                        log:printError("Error sending response", err = e)
                    };
                }
            }

            error err => {
                manageEmployeeResponse.statusCode = 500;
                manageEmployeeResponse.setPayload(err.message);
                caller->respond(manageEmployeeResponse) but { error e =>
                log:printError("Error sending response", err = e) };
            }
        }

        //Department Migration Service Invocation
        var departmentMigrationResponse = dataMigrationEP->get("/department/ADMIN");

        match departmentMigrationResponse {

            http:Response res => {
                if(res.statusCode == 200){
                    //Extract new Department ID
                    json departmentMigrationPayload = check res.getJsonPayload();
                    newDepartmentId = departmentMigrationPayload.translateResponse.targetId.toString();
                    log:printDebug("Department ID Migration : Old - " + departmentId + " Migrated - " + newDepartmentId);
                } else {
                    json errorResponse = {};
                    errorResponse.status = "Error";
                    errorResponse.message = "Error occured while migrating Department ID - No matching ID found";

                    manageEmployeeResponse.statusCode = 500;
                    manageEmployeeResponse.setJsonPayload(errorResponse);

                    caller->respond(manageEmployeeResponse) but { error e =>
                        log:printError("Error sending response", err = e)
                    };
                }
            }

            error err => {
                http:Response manageEmployeeResponse = new;
                manageEmployeeResponse.statusCode = 500;
                manageEmployeeResponse.setPayload(err.message);
                caller->respond(manageEmployeeResponse) but { error e =>
                    log:printError("Error sending response", err = e)
                };
            }
        }

        //Generate HR System payload with updated IDs from migration services
        hrSystemRequest.setJsonPayload(getHrSystemRequestPayload(employeeInfo, newEmployeeId, newDepartmentId));

        //HR System Back-end Service Invocation
        var hrSystemResponse = hrEP->execute("POST", "/employee", hrSystemRequest);

        match hrSystemResponse {

            http:Response res => {
                log:printDebug("HR System response : " + res.statusCode + " " + res.reasonPhrase);
                caller->respond(res) but { error e =>
                    log:printError("Error sending response ", err = e) };
            }

            error err => {
                manageEmployeeResponse.statusCode = 500;
                manageEmployeeResponse.setPayload(err.message);
                caller->respond(manageEmployeeResponse) but { error e =>
                    log:printError("Error sending response", err = e) };
            }
        }
    }
}

function getHrSystemRequestPayload (EmployeeInfo employeeInfo, string empId, string deptId) returns (json) {
    json requestPayload = {};
    requestPayload.employee = {};
    requestPayload.employee.name = employeeInfo.name;
    requestPayload.employee.age = employeeInfo.age;
    requestPayload.employee.city = employeeInfo.city;
    requestPayload.employee.employeeId = empId;
    requestPayload.employee.departmentId = deptId;
    requestPayload.recordId = employeeInfo.record_id;
    requestPayload.createdDate = employeeInfo.created_date;
    requestPayload.lastUpdated = employeeInfo.last_updated;
    log:printDebug("HR System Request : " + requestPayload.toString());
    return requestPayload;
}
