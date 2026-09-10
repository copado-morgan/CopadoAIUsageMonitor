public with sharing class CopadoAIActivityController {

    private static final String NAMED_CREDENTIAL = 'callout:Copado_AI_Activity';

    @AuraEnabled(cacheable=false)
    public static Copado_AI_Activity_Log__c fetchLatestActivityLog() {
        List<Copado_AI_Activity_Log__c> logs = [
            SELECT Id, Name, Fetch_Time__c, Raw_Response__c,
                   Total_Prompts__c, Total_Tokens__c, Active_Users__c
            FROM Copado_AI_Activity_Log__c
            ORDER BY Fetch_Time__c DESC
            LIMIT 1
        ];
        return logs.isEmpty() ? null : logs[0];
    }

    @AuraEnabled(cacheable=false)
    public static Copado_AI_Activity_Log__c refreshActivity() {
        String responseBody = makeActivityCall();
        return parseAndSave(responseBody);
    }

    public static void fetchAndStoreActivity() {
        try {
            String responseBody = makeActivityCall();
            parseAndSave(responseBody);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'CopadoAIActivityController.fetchAndStoreActivity error: ' + e.getMessage());
        }
    }

    @TestVisible
    private static String makeActivityCall() {
        List<Copado_AI_Config__mdt> configs = [
            SELECT Org_Id__c, Api_Key__c
            FROM Copado_AI_Config__mdt
            ORDER BY DeveloperName ASC
            LIMIT 1
        ];
        if (configs.isEmpty()) {
            throw new AuraHandledException('Copado AI configuration record not found.');
        }
        Copado_AI_Config__mdt config = configs[0];

        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + '/organizations/' + config.Org_Id__c + '/activity/summary');
        req.setMethod('GET');
        req.setHeader('X-Authorization', String.isNotBlank(config.Api_Key__c) ? config.Api_Key__c : '');
        req.setTimeout(30000);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        }
        throw new AuraHandledException('API Error ' + res.getStatusCode() + ': ' + res.getStatus());
    }

    @TestVisible
    private static Copado_AI_Activity_Log__c parseAndSave(String responseBody) {
        Copado_AI_Activity_Log__c log = new Copado_AI_Activity_Log__c();
        log.Fetch_Time__c = Datetime.now();
        log.Raw_Response__c = responseBody;

        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if (parsed.containsKey('total_prompts')) {
                log.Total_Prompts__c = Decimal.valueOf(String.valueOf(parsed.get('total_prompts')));
            }
            if (parsed.containsKey('total_tokens')) {
                log.Total_Tokens__c = Decimal.valueOf(String.valueOf(parsed.get('total_tokens')));
            }
            if (parsed.containsKey('active_users')) {
                log.Active_Users__c = Decimal.valueOf(String.valueOf(parsed.get('active_users')));
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Could not parse activity response fields: ' + e.getMessage());
        }

        insert log;
        return log;
    }
}
