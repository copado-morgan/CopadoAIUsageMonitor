import { LightningElement, track } from 'lwc';
import fetchLatestActivityLog from '@salesforce/apex/CopadoAIActivityController.fetchLatestActivityLog';
import refreshActivity from '@salesforce/apex/CopadoAIActivityController.refreshActivity';

export default class CopadoAIActivity extends LightningElement {
    @track activityLog = null;
    @track isLoading = false;
    @track errorMessage = null;

    connectedCallback() {
        this.loadLatestLog();
    }

    async loadLatestLog() {
        this.isLoading = true;
        this.errorMessage = null;
        try {
            this.activityLog = await fetchLatestActivityLog();
        } catch (error) {
            this.errorMessage = (error && error.body && error.body.message)
                ? error.body.message
                : 'Failed to load activity data.';
        } finally {
            this.isLoading = false;
        }
    }

    async handleRefresh() {
        this.isLoading = true;
        this.errorMessage = null;
        try {
            this.activityLog = await refreshActivity();
        } catch (error) {
            this.errorMessage = (error && error.body && error.body.message)
                ? error.body.message
                : 'Failed to refresh activity data.';
        } finally {
            this.isLoading = false;
        }
    }

    get hasData() {
        return !this.isLoading && this.activityLog != null;
    }

    get isEmpty() {
        return !this.isLoading && this.activityLog == null && !this.errorMessage;
    }

    get lastFetchTime() {
        if (!this.activityLog || !this.activityLog.Fetch_Time__c) return 'N/A';
        return new Date(this.activityLog.Fetch_Time__c).toLocaleString();
    }

    get totalPrompts() {
        return (this.activityLog && this.activityLog.Total_Prompts__c != null)
            ? this.activityLog.Total_Prompts__c : 'N/A';
    }

    get totalTokens() {
        return (this.activityLog && this.activityLog.Total_Tokens__c != null)
            ? this.activityLog.Total_Tokens__c : 'N/A';
    }

    get activeUsers() {
        return (this.activityLog && this.activityLog.Active_Users__c != null)
            ? this.activityLog.Active_Users__c : 'N/A';
    }

    get rawResponse() {
        if (!this.activityLog || !this.activityLog.Raw_Response__c) return '';
        try {
            return JSON.stringify(JSON.parse(this.activityLog.Raw_Response__c), null, 2);
        } catch (e) {
            return this.activityLog.Raw_Response__c;
        }
    }
}

