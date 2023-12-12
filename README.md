# Invocable Methods in Apex
## Overview
Invocable methods allow Apex to be called from various Salesforce automation tools like Flow, Process Builder, REST API, and Einstein Bots. These methods are particularly powerful in integrating Salesforce with external APIs.

**Key Points:**
- The running user must have the corresponding Apex class security set in their user profile or permission set to invoke these methods.
- Invocable methods support dynamic input and output values and can be described using describe calls.

```apex
public with sharing class ApprovalDetailsInvocable {
    
    public class Request {
        @InvocableVariable(label='Opportunity ID' required=true)
        public Id opportunityId;
    }
    
    public class Response {
        @InvocableVariable
        public Id approverId;
        
        @InvocableVariable
        public String approvalStatus;
        
        @InvocableVariable
        public String approvalComments;
    }

    @InvocableMethod(label='Get Approval Details' description='Returns approval details for a given Opportunity')
    public static List<Response> getApprovalDetails(List<Request> requests) {
        Request req = requests[0];
        Response res = new Response();
        
        List<ProcessInstance> processInstances = [
            SELECT Id, (SELECT Id, StepStatus, ActorId, Comments FROM StepsAndWorkitems ORDER BY CreatedDate DESC LIMIT 1)
            FROM ProcessInstance 
            WHERE TargetObjectId = :req.opportunityId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (!processInstances.isEmpty()) {
            ProcessInstance pi = processInstances[0];
            for (ProcessInstanceHistory step : pi.StepsAndWorkitems) {
                if (step.StepStatus == 'Approved' || step.StepStatus == 'Rejected') {
                    res.approverId = step.ActorId;
                    res.approvalStatus = step.StepStatus;
                    res.approvalComments = step.Comments;
                }
            }
        }

        return new List<Response>{ res };
    }
}
```

## InvocableMethod Considerations
**Implementation Notes**
- The method must be static and public or global.
- Only one InvocableMethod per class.
- Other annotations can't be combined with InvocableMethod.

**Inputs and Outputs**
- Input and output parameters must be lists of either primitive data types, sObject types, or user-defined types with InvocableVariable annotation.
- The data types of the inputs and outputs must be among the supported types.
- For bulkification, the inputs and outputs must correspond in size and order.


## Managed Packages
- Once included in a package, an invocable method cannot be removed in later versions.
- Public methods can be accessed within the managed package, while global methods are accessible throughout the subscriber org.


# Invocable Variables in Apex
**Definition**
- Invocable Variables are used within custom classes to define inputs and outputs for Invocable Methods.

## Usage
- These variables are annotated with **@InvocableVariable**.
- They allow the passing and receiving of data from the method.

```apex
public class Request {
    @InvocableVariable(label='Opportunity ID' required=true)
    public Id opportunityId;
}
```


**Author:** Mekan Jumayev








