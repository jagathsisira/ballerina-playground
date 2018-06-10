import ballerina/log;

string employeeElement = "employee";
string departmentElement = "department";
map<string> employeeMap = { "001": "ABA001", "002": "AXD604", "121": "GRT432", "201": "LDM043" };
map<string> departmentMap = { "FIN": "Finance", "ADMIN": "Administration", "IT": "IT", "Infrastructure": "DevOps" };

public function getNewEmployeeInfo(string employeeId) returns (json){
    json response;

    //Transform Employee ID. If mapping not found, set it to null.
    if (employeeMap.hasKey(employeeId)){
        string newEmployeeId = employeeMap[employeeId];
        log:printDebug("Employee ID migration : " + employeeId + " to " + newEmployeeId);
        response = getGenericJsonResponse(employeeElement, employeeId, newEmployeeId);
    } else {
        log:printError("Old employee ID not found in the system : " + employeeId);
        response = null;
    }

    return response;
}

public function getNewDepartmentInfo(string departmentId) returns (json){
    json response;

    //Transform Department ID. If mapping not found, set it to null.
    if (departmentMap.hasKey(departmentId)){
        string newDepartmentId = departmentMap[departmentId];
        log:printDebug("Department ID migration : " + departmentId + " to " + newDepartmentId);
        response = getGenericJsonResponse(departmentElement, departmentId, newDepartmentId);
    } else {
        log:printDebug("Old department ID not found in the system : " + departmentId);
        response = null;
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

function getErrorResponse(string informationType, string oldId) returns (json){
    json jsonObj = {};
    jsonObj.translateResponse = {};
    jsonObj.translateResponse.informationType =  informationType;
    jsonObj.translateResponse.sourceId =  oldId;
    jsonObj.translateResponse.targetId =  "";
    jsonObj.translateResponse.error =  true;
    return jsonObj;
}
