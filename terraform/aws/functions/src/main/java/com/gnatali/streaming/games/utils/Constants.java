package com.gnatali.streaming.games.utils;

public interface Constants {

    //public static final String ORIGIN_ALLOWED = System.getenv("ORIGIN_ALLOWED");
    public static final String ORIGIN_ALLOWED_SSM_PARAM = System.getenv("ORIGIN_ALLOWED_SSM_PARAM");
    public static final String KSQLDB_API_AUTH_INFO = System.getenv("KSQLDB_API_AUTH_INFO");
    public static final String KSQLDB_ENDPOINT = System.getenv("KSQLDB_ENDPOINT");

    public static final String BOOTSTRAP_SERVER = System.getenv("BOOTSTRAP_SERVER");
    public static final String KAFKA_API_KEY = System.getenv("KAFKA_API_KEY");
    public static final String KAFKA_API_SECRET = System.getenv("KAFKA_API_SECRET");
    public static final String SR_ENDPOINT = System.getenv("SR_ENDPOINT");
    public static final String SR_API_KEY = System.getenv("SR_API_KEY");
    public static final String SR_API_SECRET = System.getenv("SR_API_SECRET");

    public static final String KAFKA = "kafka";

    public static final String PLAYER_KEY = "player";
    public static final String TOPIC_KEY = "topic";
    public static final String BODY_KEY = "body";
    public static final String ORIGIN_KEY = "origin";
    public static final String HEADERS_KEY = "headers";
    public static final String QUERY_PARAMS_KEY = "queryStringParameters";
    public static final String POST_METHOD = "POST";

    public static final String ENDPOINT_PARAMETER = "endpoint";
    public static final String QUERY_PARAMETER = "ksql";
    public static final String KSQLDB_ENDPOINT_QUERY = "query-stream";
    public static final String KSQLDB_ENDPOINT_KSQL = "ksql";

    public static final String USER_GAME_TOPIC = "USER_GAME";
    public static final String USER_LOSSES_TOPIC = "USER_LOSSES";
    public static final String SCOREBOARD_TOPIC = "SCOREBOARD";
    public static final String SCOREBOARD_FIELD = "scoreboard";
    public static final String USER_FIELD = "USER";
    public static final String HIGHEST_SCORE_FIELD = "HIGHEST_SCORE";
    public static final String HIGHEST_LEVEL_FIELD = "HIGHEST_LEVEL";
    public static final String TOTAL_LOSSES_FIELD = "TOTAL_LOSSES";
    

   

}
