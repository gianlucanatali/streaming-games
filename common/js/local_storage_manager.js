window.fakeStorage = {
  _data: {},

  setItem: function (id, val) {
    return this._data[id] = String(val);
  },

  getItem: function (id) {
    return this._data.hasOwnProperty(id) ? this._data[id] : undefined;
  },

  removeItem: function (id) {
    return delete this._data[id];
  },

  clear: function () {
    return this._data = {};
  }
};

function LocalStorageManager() {
  this.bestScoreKey     = "bestScore";
  this.gameStateKey     = "gameState";
  this.scoreboardInterval     = "scoreboardInterval";
  this.gameNameKey     = "gameName";
  this.usernameKey     = "username";
  this.playersScoresKey = "playersScores";

  var supported = this.localStorageSupported();
  this.storage = supported ? window.localStorage : window.fakeStorage;
}

LocalStorageManager.prototype.localStorageSupported = function () {
  var testKey = "test";

  try {
    var storage = window.localStorage;
    storage.setItem(testKey, "1");
    storage.removeItem(testKey);
    return true;
  } catch (error) {
    return false;
  }
};

// Scoreboard Interval getters/setters 
LocalStorageManager.prototype.getScoreboardInterval = function () {
  return this.storage.getItem(this.scoreboardInterval) || null;
};

LocalStorageManager.prototype.setScoreboardInterval = function (scoreboardInterval) {
  this.storage.setItem(this.scoreboardInterval, scoreboardInterval);
};

// Game name getters/setters 
LocalStorageManager.prototype.getGameName = function () {
  return this.storage.getItem(this.gameNameKey) || null;
};

LocalStorageManager.prototype.setGameName = function (gameName) {
  this.storage.setItem(this.gameNameKey, gameName);
};

// User name getters/setters 
LocalStorageManager.prototype.getUsername = function () {
  return this.storage.getItem(this.usernameKey) || null;
};

LocalStorageManager.prototype.setUsername = function (username) {
  this.storage.setItem(this.usernameKey, username);
};

// PlayersScore getters/setters 
LocalStorageManager.prototype.getPlayersScores = function () {
  var gameName = this.getGameName();
  return JSON.parse(this.storage.getItem(gameName+"_"+this.playersScoresKey)) || null;
};

LocalStorageManager.prototype.setPlayersScores = function (playersScores) {
  var gameName = this.getGameName();
  this.storage.setItem(gameName+"_"+this.playersScoresKey, JSON.stringify(playersScores));
};


// Best score getters/setters
LocalStorageManager.prototype.getBestScore = function () {
  var gameName = this.getGameName();
  var username = this.getUsername();
  return this.storage.getItem(gameName+"_"+username+"_"+this.bestScoreKey) || 0;
};

LocalStorageManager.prototype.setBestScore = function (score) {
  var gameName = this.getGameName();
  var username = this.getUsername();
  this.storage.setItem(gameName+"_"+username+"_"+this.bestScoreKey, score);
};

// Game state getters/setters and clearing
LocalStorageManager.prototype.getGameState = function () {
  var gameName = this.getGameName();
  var username = this.getUsername();
  var stateJSON = this.storage.getItem(gameName+"_"+username+"_"+this.gameStateKey);
  return stateJSON ? JSON.parse(stateJSON) : null;
};

LocalStorageManager.prototype.setGameState = function (gameState) {
  var gameName = this.getGameName();
  var username = this.getUsername();
  this.storage.setItem(gameName+"_"+username+"_"+this.gameStateKey, JSON.stringify(gameState));
};

LocalStorageManager.prototype.clearGameState = function () {
  var gameName = this.getGameName();
  var username = this.getUsername();
  this.storage.removeItem(gameName+"_"+username+"_"+this.gameStateKey);
};



