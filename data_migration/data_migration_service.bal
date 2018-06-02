import ballerina/io;
import ballerina/http;
import ballerina/log;

endpoint http:Listener TranslateListener {
    port:9022
};

@http:ServiceConfig {
    basePath: "/data-migration"
}

service<http:Service> employeeMigrationService bind TranslateListener {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/employee/{employeeId}"
    }

    getEmployee (endpoint caller, http:Request translateRequest, string employeeId) {
        http:Response jsonResponse = new;
        jsonResponse.setJsonPayload(translateEmployee(employeeId));
        _ = caller->respond(jsonResponse);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/department/{departmentId}"
    }

    getDepartment (endpoint caller, http:Request translateRequest, string departmentId) {
        http:Response jsonResponse = new;
        jsonResponse.setJsonPayload(translateDepartment(departmentId));
        _ = caller->respond(jsonResponse);
    }
}
