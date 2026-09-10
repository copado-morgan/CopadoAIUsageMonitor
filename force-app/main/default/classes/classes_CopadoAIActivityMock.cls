@isTest
public class CopadoAIActivityMock implements HttpCalloutMock {

    private final Integer statusCode;
    private final String responseBody;

    public CopadoAIActivityMock(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
}
