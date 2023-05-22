var localStoreManager = new LocalStorageManager;

window.requestAnimationFrame(function () {
    checkName();
    createGameSelector();
});

function checkName() {
    var username = localStoreManager.getUsername();
    if (username != null && username.length > 0) {
        document.getElementById("user").value = username;
    }
    
}

function enter(e) {
    if (e.which == 13 || e.keyCode == 13) {
        play();
    }
}

function play() {
    var user = document.getElementById("user").value;
    var selected_game=$("input[type='radio'][name='game_input']:checked").val();
    if (user == '') {
        alert('You need to provide a name.');
        return;
    }
    if (!selected_game) {
        //Using a default to let people play a game if the input doesn't show up...
        selected_game = GAMES_LIST[0];
        /*alert('You need to select a game.');
        return;*/
    }
    localStoreManager.setUsername(user);
    localStoreManager.setGameName(selected_game);
    window.location.href = selected_game+"/index.html";
}

function createGameSelector() {
    var htmlCode=""
   
    if (GAMES_LIST == '') {
        alert('Error, games list empty');
        return;
    }
    var json = GAMES_LIST;

    json.forEach((row, index) => {
        htmlCode += '<div class"gameSelectorOpt">';
		htmlCode += '<input type="radio" id="' + row + '" name="game_input" value="' + row + '" '+(index==0?' checked="checked"':'')+'>';
        htmlCode += '<label for="' + row + '">' + row + '</label>';
        htmlCode += '</div>';
	});

    document.getElementById('gameSelector').innerHTML = htmlCode;
}

/**
 * 
 * <input type="radio" id="html" name="fav_language" value="HTML">
          <label for="html">HTML</label><br>
          <input type="radio" id="css" name="fav_language" value="CSS">
          <label for="css">CSS</label><br>
          <input type="radio" id="javascript" name="fav_language" value="JavaScript">
          <label for="javascript">JavaScript</label>
 */


