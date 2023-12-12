public class DynamicApprovalRouting {

    public class ApprovalRequest {
        @InvocableVariable(required=true)
        public Id recordId;

        @InvocableVariable(required=true)
        public String market;
    }

    public class ApprovalResponse {
        @InvocableVariable
        public Boolean isSuccess;
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Submit Record for Approval based on Territory')
    public static List<ApprovalResponse> submitForApproval(List<ApprovalRequest> requests) {
        List<ApprovalResponse> responses = new List<ApprovalResponse>();
        for (ApprovalRequest req : requests) {
            List<Id> approverIds = getApprovers();

            ApprovalResponse response = new ApprovalResponse();
            response.isSuccess = submitRecordForApproval(req.recordId, approverIds, response);
            responses.add(response);
        }
        return responses;
    }
    
    private static List<Id> getApprovers() {
        List<Group> queueList = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'queue name' LIMIT 1];
        List<Id> queueIds = new List<Id>();
        for (Group g : queueList) {
            queueIds.add(g.Id);
        }
        return queueIds;
    }


    private static Boolean submitRecordForApproval(Id recordId, List<Id> approverIds, ApprovalResponse response) {
        if (approverIds.isEmpty()) {
            response.message = 'No approvers found in the specified territories.';
            return false;
        }

        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setObjectId(recordId);

        if (!approverIds.isEmpty()) {
            approvalRequest.setNextApproverIds(approverIds);
        }

        try {
            Approval.ProcessResult result = Approval.process(approvalRequest);
            response.message = '';
            return true; // Successful submission
        } catch (Exception e) {
            System.debug('Approval process error: ' + e);
            response.message = e.getMessage();
            return false; // Failed submission
        }
    }
}