public class CopadoAIActivityScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new CopadoAIActivityFetcher());
    }
}
