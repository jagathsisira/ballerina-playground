import ballerina/io;
import ballerina/log;

map<string> employeeMap = { "001": "ABA001", "002": "AXD604", "121": "GRT432", "201": "LDM043" };
map<string> departmentMap = { "FIN": "Finance", "ADMIN": "Administration", "IT": "IT", "Infrastructure": "DevOps" };

public function translateEmployee(string employeeId) returns (json){
    json response;

    try {
        string newEmployeeId = <string>employeeMap[employeeId];
        io:println("Employee ID migration : " + employeeId + " to " + newEmployeeId);
        response = getGenericJsonResponse("employee", employeeId, newEmployeeId);
    } catch (error err){
        io:println("Error occured in Employee Translation : " + err.message);
        response = getRecordNotFoundResponse("employee", employeeId);
    }

    return response;
}

public function translateDepartment(string departmentId) returns (json){
    json response;

    try {
        string newDepartmentId = <string>departmentMap[departmentId];
        io:println("Department ID migration : " + departmentId + " to " + newDepartmentId);
        response = getGenericJsonResponse("department", departmentId, newDepartmentId);
    } catch (error err){
        io:println("Error occured in Department Translation : " + err.message);
        response = getRecordNotFoundResponse("department", departmentId);
    }

    return response;
}

function getGenericJsonResponse(string informationType, string oldId, string newId) returns (json){
    json jsonObj = {};
    jsonObj.translateResponse = {};
    jsonObj.translateResponse.informationType =  informationType;
    jsonObj.translateResponse.sourceId =  oldId;
    jsonObj.translateResponse.targetId =  newId;
    return jsonObj;
}

function getRecordNotFoundResponse(string informationType, string oldId) returns (json){
    json jsonObj = {};
    jsonObj.translateResponse = {};
    jsonObj.translateResponse.informationType =  informationType;
    jsonObj.translateResponse.sourceId =  oldId;
    jsonObj.translateResponse.error =  "Record Not Found";
    return jsonObj;
}