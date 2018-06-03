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
        http:Response callerResponse = new;
        json responseJson = translateEmployee(employeeId);

        if(responseJson != null){
            callerResponse.setJsonPayload(responseJson);
        } else {
            callerResponse.statusCode = 404;
        }

        _ = caller->respond(callerResponse);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/department/{departmentId}"
    }

    getDepartment (endpoint caller, http:Request translateRequest, string departmentId) {
        http:Response callerResponse = new;
        json responseJson = translateDepartment(departmentId);

        if(responseJson != null){
            callerResponse.setJsonPayload(responseJson);
        } else {
            callerResponse.statusCode = 404;
        }

        _ = caller->respond(callerResponse);
    }
}
