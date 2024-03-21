
function produceToUserGame(user,gameName, score, lives, level) {

	var payload = {}
	payload.topic = "USER_GAME"
	payload.user= user
	payload.game_name = gameName
	payload.score = score
	payload.lives = lives
	payload.level = level

	const request = new XMLHttpRequest();
	sendToKafka(request, payload);

}

function produceToUserLosses(user,gameName) {

	var payload = {}
	payload.topic = "USER_LOSSES"
	payload.user= user
	payload.game_name = gameName

	const request = new XMLHttpRequest();
	sendToKafka(request, payload);

}


function loadHighestScore(gameName, user, ctx, callback ) {

	var highestScore ;
	
	ksqlQuery = `SELECT HIGHEST_SCORE FROM STATS_PER_USER WHERE ROWKEY->USER='${user}' AND ROWKEY->GAME_NAME='${gameName}';`;

	var request = new XMLHttpRequest();
    request.onreadystatechange = function() {
        if (this.readyState == 4) {
			if (this.status == 200) {
				var result = JSON.parse(this.responseText);
				if (result[1] != undefined || result[1] != null) {
					var row = result[1];
					highestScore = row[0];
				}
            }
            callback(highestScore, ctx);
		}
	};
	sendksqlDBQuery(request, ksqlQuery);

}


function getScoreboardJson(gameName,callback) {

	ksqlQuery = `SELECT ROWKEY->USER, HIGHEST_SCORE, HIGHEST_LEVEL, TOTAL_LOSSES FROM STATS_PER_USER WHERE ROWKEY->GAME_NAME='${gameName}';`;

	const request = new XMLHttpRequest();
	request.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			var result = JSON.parse(this.responseText);
			if (result[1] == undefined || result[1] == null) {
				logger('Empty Scoreboard')
				return;
			}

			//First element is the header
			result.shift();
			var playersScores = result.map((item) => ({ user: item[0], score:item[1],level:item[2],losses:item[3] }));

			playersScores = playersScores.sort(function(a, b) {
				var res=0

				if (a.score > b.score) res = 1;
				if (b.score > a.score) res = -1;
				if (a.score == b.score){
					if (a.level > b.level) res = 1;
					if (b.level > a.level) res = -1;
					if (a.level == b.level){
						if (a.losses < b.losses) res = 1;
						if (b.losses > a.losses) res = -1;
					} 
				} 
				return res * -1;
			});;
			callback(playersScores);
		}
	};
	
	sendksqlDBQuery(request, ksqlQuery);

}


function sendksqlDBStmt(request, ksqlQuery){
	var query = {};
	query.ksql = ksqlQuery;
	query.endpoint = "ksql";
	request.open('POST', KSQLDB_QUERY_API, true);
	request.setRequestHeader('Accept', 'application/json');
	request.setRequestHeader('Content-Type', 'application/json');
	request.send(JSON.stringify(query));
}

function sendksqlDBQuery(request, ksqlQuery){
	var query = {};
	query.sql = ksqlQuery;
	query.endpoint = "query-stream";
	request.open('POST', KSQLDB_QUERY_API, true);
	request.setRequestHeader('Accept', 'application/json');
	request.setRequestHeader('Content-Type', 'application/json');
	request.send(JSON.stringify(query));
}

function sendToKafka(request, payload){
	payload.endpoint = "kafka";
	request.open('POST', KSQLDB_QUERY_API, true);
	request.setRequestHeader('Accept', 'application/json');
	request.setRequestHeader('Content-Type', 'application/json');
	request.send(JSON.stringify(payload));
}
