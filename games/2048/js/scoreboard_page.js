var localStoreManager = new LocalStorageManager;


window.requestAnimationFrame(function () {
    localStoreManager.setGameName("2048");
    var bestContainer    = document.querySelector(".best-container");
    bestContainer.textContent = localStoreManager.getBestScore() ;
    fillScoreboardPage(localStoreManager);
    loadScoreboard(localStoreManager);

    setUpScoreboardDeamonLoader(localStoreManager, 1000, true)

});
