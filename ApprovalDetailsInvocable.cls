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