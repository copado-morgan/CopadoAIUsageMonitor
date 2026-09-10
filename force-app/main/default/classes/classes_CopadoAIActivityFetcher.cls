public class CopadoAIActivityFetcher implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext ctx) {
        CopadoAIActivityController.fetchAndStoreActivity();
    }
}
