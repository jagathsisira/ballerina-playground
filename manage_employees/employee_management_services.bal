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
    url: "http://localhost:9023/hr"
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
        path: "/employees"
    }
    addEmployee(endpoint caller, http:Request addEmployeeRequest) {
        http:Request hrSystemRequest = new;
        json requestJson = {};
        string newEmployeeId;
        string newDepartmentId;

        //Process request JSON payload and validate
        match (addEmployeeRequest.getJsonPayload()) {
            json inputPayload => {
                requestJson = inputPayload;
            }
            error err => {
                log:printError("Employee information received not in correct format : ", err = err);
                caller->respond(getHttpResponse(400, "Bad Request - Invalid Payload")) but { error e =>
                    log:printError("Error sending response", err = e) };
                done;
            }
        }

        log:printDebug("Employee information received : " + requestJson.toString());

        //Extract values from received payload
        EmployeeInfo employeeInfo = check <EmployeeInfo>requestJson;
        string employeeId = employeeInfo.employee_id;
        string departmentId = employeeInfo.department_id;

        //Employee Migration Service Invocation
        var employeeMigrationResponse = dataMigrationEP->get("/employees/" + untaint employeeId);

        //Process the response
        match employeeMigrationResponse {

            http:Response res => {
                if(res.statusCode == 200){
                    //Extract new Employee ID
                    json employeeMigrationPayload = check res.getJsonPayload();
                    newEmployeeId = employeeMigrationPayload.translateResponse.targetId.toString();
                    log:printDebug("Employee ID Migration : Old - " + employeeId + " Migrated - " + newEmployeeId);
                } else if(res.statusCode == 404) {
                    caller->respond(getHttpResponse(500, "Error occured while processing the request - No matching "
                                + "Employee ID found")) but { error e =>
                        log:printError("Error sending response ", err = e)
                    };
                    done;
                } else {
                    caller->respond(getHttpResponse(500, "Error occured while processing the request")) but { error e =>
                        log:printError("Error sending response ", err = e)
                    };
                    done;
                }
            }

            error err => {
                log:printError("Error invoking Employee Migration Service : ", err = err);
                caller->respond(getHttpResponse(500, err.message)) but { error e =>
                    log:printError("Error sending response", err = e) };
                done;
            }
        }

        //Department Migration Service Invocation
        var departmentMigrationResponse = dataMigrationEP->get("/departments/" + untaint departmentId);

        //Process the response
        match departmentMigrationResponse {

            http:Response res => {
                if(res.statusCode == 200){
                    //Extract new Department ID
                    json departmentMigrationPayload = check res.getJsonPayload();
                    newDepartmentId = departmentMigrationPayload.translateResponse.targetId.toString();
                    log:printDebug("Department ID Migration : Old - " + departmentId + " Migrated - " + newDepartmentId);
                } else if(res.statusCode == 404) {
                    caller->respond(getHttpResponse(500, "Error occured while processing the request - No matching "
                                + "Department ID found")) but { error e =>
                        log:printError("Error sending response ", err = e)
                    };
                    done;
                } else {
                    caller->respond(getHttpResponse(500, "Error occured while processing the request")) but { error e =>
                    log:printError("Error sending response ", err = e)
                    };
                    done;
                }
            }

            error err => {
                log:printError("Error invoking Department Migration Service : ", err = err);
                caller->respond(getHttpResponse(500, err.message)) but { error e =>
                    log:printError("Error sending response", err = e)
                };
                done;
            }
        }

        //Generate HR System payload with updated IDs from migration services
        hrSystemRequest.setJsonPayload(getHrSystemRequestPayload(employeeInfo, newEmployeeId, newDepartmentId));

        //HR System Back-end Service Invocation
        var hrSystemResponse = hrEP->execute("POST", "/employees", hrSystemRequest);

        //Process the response
        match hrSystemResponse {

            http:Response res => {
                log:printDebug("HR System response : " + res.statusCode + " " + res.reasonPhrase);
                caller->respond(res) but { error e =>
                    log:printError("Error sending response ", err = e) };
            }

            error err => {
                caller->respond(getHttpResponse(500, err.message)) but { error e =>
                    log:printError("Error sending response", err = e) };
            }
        }
    }
}

function getHttpResponse(int statusCode, string payload) returns (http:Response) {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setContentType("application/json");
    if(payload != null){
        response.setJsonPayload({"message" : "Error in processing request - " + payload});
    }
    return response;
}

function getHrSystemRequestPayload(EmployeeInfo employeeInfo, string empId, string deptId) returns (json) {
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
