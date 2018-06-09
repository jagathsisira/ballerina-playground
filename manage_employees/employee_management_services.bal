import ballerina/http;
import ballerina/log;

endpoint http:Listener EmployeeMgtServiceListener {
    port:9024
};

endpoint http:Client clientEP {
    url: "http://localhost:9023/hr/employee-mgt"
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
        var clientResponse = clientEP->forward("/employee", addEmployeeRequest);

        match clientResponse {

            http:Response res => {
                caller->respond(res) but { error e =>
                    log:printError("Error sending response", err = e) };
            }

            error err => {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(err.message);
                caller->respond(res) but { error e =>
                    log:printError("Error sending response", err = e) };
            }
        }
    }
}
