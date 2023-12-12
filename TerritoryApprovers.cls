public class TerritoryApprovers {

    public class Request {
        @InvocableVariable(label='Territory Name')
        public String territoryName;
    }

    public class Response {
        @InvocableVariable(label='Level1 Approver')
        public String level1Approver;
        @InvocableVariable(label='Level2 Approver')
        public String level2Approver;
        @InvocableVariable(label='Level3 Approver')
        public String level3Approver;
        @InvocableVariable(label='Level4 Approver')
        public String level4Approver;
        @InvocableVariable(label='Level5 Approver')
        public String level5Approver;
        @InvocableVariable(label='Level6 Approver')
        public String level6Approver;
        @InvocableVariable(label='Level7 Approver')
        public String level7Approver;
        @InvocableVariable(label='Level8 Approver')
        public String level8Approver;
        @InvocableVariable(label='Level9 Approver')
        public String level9Approver;
        @InvocableVariable(label='Level10 Approver')
        public String level10Approver;
    }

    @InvocableMethod(label='Get Territory Approvers' description='Returns up to 10 approvers from the specified territory')
    public static List<Response> getTerritoryApprovers(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            List<UserTerritory2Association> userTerrAssociations = [
                SELECT UserId
                FROM UserTerritory2Association
                WHERE Territory2.Name = :req.territoryName OR Territory2.Name = 'All Locations'
                LIMIT 10
            ];

            Response res = new Response();
            for (Integer i = 0; i < userTerrAssociations.size(); i++) {
                Id userId = userTerrAssociations[i].UserId;
                switch on i {
                    when 0 { res.level1Approver = userId; }
                    when 1 { res.level2Approver = userId; }
                    when 2 { res.level3Approver = userId; }
                    when 3 { res.level4Approver = userId; }
                    when 4 { res.level5Approver = userId; }
                    when 5 { res.level6Approver = userId; }
                    when 6 { res.level7Approver = userId; }
                    when 7 { res.level8Approver = userId; }
                    when 8 { res.level9Approver = userId; }
                    when 9 { res.level10Approver = userId; }
                }
            }
            responses.add(res);
        }
        return responses;
    }
}