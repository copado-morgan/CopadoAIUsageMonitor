@isTest
public class CopadoAIActivitySchedulerTest {

    private static final String MOCK_SUCCESS = '{"total_prompts":150,"total_tokens":45000,"active_users":12}';
    private static final String CRON_EXP = '0 0 * * * ?';

    @isTest
    static void testSchedulerCanBeScheduled() {
        Test.startTest();
        String jobId = System.schedule('Test Copado AI Scheduler', CRON_EXP, new CopadoAIActivityScheduler());
        Test.stopTest();
        List<CronTrigger> triggers = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(1, triggers.size(), 'Scheduler should be registered as a cron job.');
    }

    @isTest
    static void testFetcherCreatesActivityLog() {
        Test.setMock(HttpCalloutMock.class, new CopadoAIActivityMock(200, MOCK_SUCCESS));
        Test.startTest();
        System.enqueueJob(new CopadoAIActivityFetcher());
        Test.stopTest();
        List<Copado_AI_Activity_Log__c> logs = [SELECT Id, Total_Prompts__c FROM Copado_AI_Activity_Log__c];
        System.assertEquals(1, logs.size(), 'Fetcher should create one activity log record.');
        System.assertEquals(150, logs[0].Total_Prompts__c, 'Total prompts should be 150.');
    }
}
