@isTest
public class CopadoAIActivityControllerTest {

    private static final String MOCK_SUCCESS = '{"total_prompts":150,"total_tokens":45000,"active_users":12}';
    private static final String MOCK_ERROR   = '{"error":"Internal Server Error"}';

    @isTest
    static void testRefreshActivitySuccess() {
        Test.setMock(HttpCalloutMock.class, new CopadoAIActivityMock(200, MOCK_SUCCESS));
        Test.startTest();
        Copado_AI_Activity_Log__c log = CopadoAIActivityController.refreshActivity();
        Test.stopTest();
        System.assertNotEquals(null, log.Id, 'Log record should be inserted.');
        System.assertEquals(150, log.Total_Prompts__c, 'Total prompts should be 150.');
        System.assertEquals(45000, log.Total_Tokens__c, 'Total tokens should be 45000.');
        System.assertEquals(12, log.Active_Users__c, 'Active users should be 12.');
        System.assertEquals(MOCK_SUCCESS, log.Raw_Response__c, 'Raw response should match.');
    }

    @isTest
    static void testRefreshActivityApiError() {
        Test.setMock(HttpCalloutMock.class, new CopadoAIActivityMock(500, MOCK_ERROR));
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            CopadoAIActivityController.refreshActivity();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'AuraHandledException should be thrown on API error.');
    }

    @isTest
    static void testFetchLatestActivityLogWithData() {
        Copado_AI_Activity_Log__c seedLog = new Copado_AI_Activity_Log__c(
            Fetch_Time__c    = Datetime.now(),
            Raw_Response__c  = MOCK_SUCCESS,
            Total_Prompts__c = 100,
            Total_Tokens__c  = 30000,
            Active_Users__c  = 5
        );
        insert seedLog;
        Test.startTest();
        Copado_AI_Activity_Log__c result = CopadoAIActivityController.fetchLatestActivityLog();
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result should not be null when data exists.');
        System.assertEquals(100, result.Total_Prompts__c, 'Total prompts should match seed data.');
    }

    @isTest
    static void testFetchLatestActivityLogEmpty() {
        Test.startTest();
        Copado_AI_Activity_Log__c result = CopadoAIActivityController.fetchLatestActivityLog();
        Test.stopTest();
        System.assertEquals(null, result, 'Result should be null when no logs exist.');
    }

    @isTest
    static void testFetchAndStoreActivitySuccess() {
        Test.setMock(HttpCalloutMock.class, new CopadoAIActivityMock(200, MOCK_SUCCESS));
        Test.startTest();
        CopadoAIActivityController.fetchAndStoreActivity();
        Test.stopTest();
        List<Copado_AI_Activity_Log__c> logs = [SELECT Id FROM Copado_AI_Activity_Log__c];
        System.assertEquals(1, logs.size(), 'One activity log should be created.');
    }

    @isTest
    static void testFetchAndStoreActivityNoConfig() {
        Boolean exceptionCaught = false;
        try {
            CopadoAIActivityController.makeActivityCall();
        } catch (AuraHandledException e) {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught, 'Should throw when no config exists.');
    }
}
