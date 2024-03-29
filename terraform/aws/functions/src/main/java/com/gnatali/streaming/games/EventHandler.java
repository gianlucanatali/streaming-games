package com.gnatali.streaming.games;

import static com.gnatali.streaming.games.utils.Constants.BODY_KEY;
import static com.gnatali.streaming.games.utils.Constants.HEADERS_KEY;
import static com.gnatali.streaming.games.utils.Constants.ORIGIN_KEY;
import static com.gnatali.streaming.games.utils.Constants.POST_METHOD;
import static com.gnatali.streaming.games.utils.Constants.ORIGIN_ALLOWED_SSM_PARAM;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.exception.ExceptionUtils;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.gnatali.streaming.games.utils.BasicAuthInterceptor;
import com.gnatali.streaming.games.utils.Constants;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import software.amazon.awssdk.services.ssm.SsmClient;
import software.amazon.awssdk.services.ssm.model.GetParameterRequest;
import software.amazon.awssdk.services.ssm.model.GetParameterResponse;
import software.amazon.awssdk.services.ssm.model.SsmException;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import com.gnatali.streaming.games.avro.UserGame;
import com.gnatali.streaming.games.avro.UserLosses;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

public class EventHandler implements RequestHandler<Map<String, Object>, Map<String, Object>> {

    public static final MediaType MEDIATYPE_JSON = MediaType.parse("application/json; charset=utf-8");
    public static final MediaType MEDIATYPE_KSQL = MediaType.parse("application/vnd.ksql.v1+json; charset=utf-8");

    String username = Constants.KSQLDB_API_AUTH_INFO.split(":")[0];
    String password = Constants.KSQLDB_API_AUTH_INFO.split(":")[1];

    Gson gson = new GsonBuilder().setPrettyPrinting().create();

    OkHttpClient client = new OkHttpClient.Builder()
            .addInterceptor(new BasicAuthInterceptor(username, password))
            .build();

    public KafkaProducerPropertiesFactory kafkaProducerProperties = new KafkaProducerPropertiesFactoryImpl();
    private KafkaProducer<String, UserGame> userGameProducer;
    private KafkaProducer<String, UserLosses> userLossesProducer;

    private String post(String url, String json, String accept) throws IOException {
        RequestBody body = RequestBody.create(json, MEDIATYPE_KSQL);
        okhttp3.Request.Builder requestBuilder = new Request.Builder()
                .url(url);

        if (accept != null) {
            requestBuilder.addHeader("Accept", accept);
        }

        Request request = requestBuilder
                .post(body)
                .build();
        try (Response response = client.newCall(request).execute()) {
            return response.body().string();
        }
    }

    private KafkaProducer<String, UserGame> createUserGameProducer() {
        if (userGameProducer == null) {
            userGameProducer = new KafkaProducer<String, UserGame>(kafkaProducerProperties.getProducerProperties());
        }
        return userGameProducer;
    }

    private KafkaProducer<String, UserLosses> createUserLossesProducer() {
        if (userLossesProducer == null) {
            userLossesProducer = new KafkaProducer<String, UserLosses>(kafkaProducerProperties.getProducerProperties());
        }
        return userLossesProducer;
    }

    public Map<String, Object> handleRequest(final Map<String, Object> request, final Context context) {

        LambdaLogger logger = context.getLogger();

        logger.log("ENVIRONMENT VARIABLES: " + gson.toJson(System.getenv()));
        logger.log("CONTEXT: " + gson.toJson(context));

        String result;

        Map<String, Object> response = new HashMap<>();
        if (!request.containsKey(HEADERS_KEY)) {
            result = "Thanks for waking me up";
            response.put(BODY_KEY, result);
            logger.log("Function wake up received");
            return response;
        }

        @SuppressWarnings("unchecked")
        Map<String, Object> requestHeaders = (Map<String, Object>) request.get(HEADERS_KEY);

        if (requestHeaders.containsKey(ORIGIN_KEY)) {
    
            SsmClient ssmClient = SsmClient.create();

            logger.log("Retrieving SSM parameter: " + ORIGIN_ALLOWED_SSM_PARAM);
            String originAllowedFromSSM = getParaValue(ssmClient,  ORIGIN_ALLOWED_SSM_PARAM );
            ssmClient.close();
            logger.log("Retrieved SSM parameter value is: " + originAllowedFromSSM);

            String origin = (String) requestHeaders.get(ORIGIN_KEY);
            logger.log("Function origin is " + origin);
            logger.log("Origin Allowed is " + originAllowedFromSSM);

            if (origin.equals(originAllowedFromSSM)) {
                if (request.containsKey(BODY_KEY)) {
                    String event = (String) request.get(BODY_KEY);

                    logger.log("EVENT: " + gson.toJson(event));
                    logger.log("EVENT TYPE: " + event.getClass().toString());

                    if (event != null) {

                        JsonElement payloadRoot = JsonParser.parseString(event);

                        String payloadEndpoint = payloadRoot.getAsJsonObject().get("endpoint").getAsString();
                        String payloadQuery;

                        logger.log("payloadEndpoint: " + payloadEndpoint);

                        String endpoint;
                        String queryObjName;
                        String accept = null;

                        if (Constants.KSQLDB_ENDPOINT_QUERY.equals(payloadEndpoint)) {
                            endpoint = Constants.KSQLDB_ENDPOINT_QUERY;
                            queryObjName = "sql";
                            accept = "application/json";
                            
                        } else if (Constants.KSQLDB_ENDPOINT_KSQL.equals(payloadEndpoint)) {
                            endpoint = Constants.KSQLDB_ENDPOINT_KSQL;
                            queryObjName = "ksql";

                        } else if (Constants.KAFKA.equals(payloadEndpoint)) {
                            String topic = payloadRoot.getAsJsonObject().get("topic").getAsString();
                            if ("USER_GAME".equals(topic)) {
                                
                                final UserGame msg = new UserGame (
                                    payloadRoot.getAsJsonObject().get("user").getAsString(),
                                    payloadRoot.getAsJsonObject().get("game_name").getAsString(),
                                    payloadRoot.getAsJsonObject().get("score").getAsInt(),
                                    payloadRoot.getAsJsonObject().get("lives").getAsInt(),
                                    payloadRoot.getAsJsonObject().get("level").getAsInt()
                                );
                                KafkaProducer<String, UserGame> userGameProducer = createUserGameProducer();
                                userGameProducer.send(new ProducerRecord<>(topic,null,msg));

                            } else if ("USER_LOSSES".equals(topic)) {
                                
                                final UserLosses msg = new UserLosses(
                                    payloadRoot.getAsJsonObject().get("user").getAsString(),
                                    payloadRoot.getAsJsonObject().get("game_name").getAsString()
                                );
                                KafkaProducer<String, UserLosses> userLossesProducer = createUserLossesProducer();
                                userLossesProducer.send(new ProducerRecord<>(topic, null, msg));

                            }
                            return response;

                        } else {
                            StringBuilder message = new StringBuilder();
                            message.append("The endpoint provided (" + payloadEndpoint + ") is not supported");
                            result = message.toString();
                            response.put(BODY_KEY, result);

                            return response;
                        }

                        payloadQuery = payloadRoot.getAsJsonObject().get(queryObjName).getAsString();
                        logger.log("payloadQuery: " + payloadQuery);

                        JsonObject newPayload = new JsonObject();
                        newPayload.add(queryObjName, payloadRoot.getAsJsonObject().get(queryObjName));

                        try {
                            logger.log("Sending POST to : " + Constants.KSQLDB_ENDPOINT + "/" + endpoint);
                            logger.log("Payload : " + gson.toJson(newPayload));
                            result = post(Constants.KSQLDB_ENDPOINT + "/" + endpoint, gson.toJson(newPayload), accept);
                            logger.log("Post worked: " + endpoint + " result: " + result);
                        } catch (Exception e) {
                            logger.log("Error! " + e.getMessage());
                            logger.log(ExceptionUtils.getStackTrace(e));
                            StringBuilder message = new StringBuilder();
                            message.append("Error in executing the query ");
                            message.append(payloadQuery);
                            message.append(e.getMessage());
                            response.put(BODY_KEY, message.toString());

                            return response;
                        }

                        response.put(BODY_KEY, result);

                        Map<String, Object> responseHeaders = new HashMap<>();
                        responseHeaders.put("Access-Control-Allow-Headers", "*");
                        responseHeaders.put("Access-Control-Allow-Methods", POST_METHOD);
                        responseHeaders.put("Access-Control-Allow-Origin", originAllowedFromSSM);
                        response.put(HEADERS_KEY, responseHeaders);

                    } else {
                        logger.log("Didn't enter first IF!");
                    }

                }

            }

        } else {
            logger.log("No origin!");
        }

        logger.log("Response will be sent : " + gson.toJson(response));
        return response;

    }

    public static String getParaValue(SsmClient ssmClient, String paraName) {

        String res = "";
        try {
            GetParameterRequest parameterRequest = GetParameterRequest.builder()
                    .name(paraName)
                    .build();

            GetParameterResponse parameterResponse = ssmClient.getParameter(parameterRequest);
            System.out.println("The parameter value is " + parameterResponse.parameter().value());
            res = parameterResponse.parameter().value();

        } catch (SsmException e) {
            System.err.println(e.getMessage());
            System.exit(1);
        }
        return res;
    }

}
