var CLASSIC_GAMEDIRECTION = 3;
var CLASSIC_GAMEDIRECTION_TRY = -1;
var CLASSIC_GAMEDIRECTION_TRY_TIMER = null;
var CLASSIC_GAMEDIRECTION_TRY_CANCEL = 1000;
var CLASSIC_GAMEPOSITION_X = 276;
var CLASSIC_GAMEPOSITION_Y = 416;
var CLASSIC_GAMEPOSITION_STEP = 2;
var CLASSIC_GAMEMOUNTH_STATE = 3;
var CLASSIC_GAMEMOUNTH_STATE_MAX = 6;
var CLASSIC_GAMESIZE = 16;
var CLASSIC_GAMEMOVING = false;
var CLASSIC_GAMEMOVING_TIMER = -1;
var CLASSIC_GAMEMOVING_SPEED = 15;
var CLASSIC_GAMECANVAS_CONTEXT = null;
var CLASSIC_GAMEEAT_GAP = 15;
var CLASSIC_GAMEGHOST_GAP = 20;
var CLASSIC_GAMEFRUITS_GAP = 15;
var CLASSIC_GAMEKILLING_TIMER = -1;
var CLASSIC_GAMEKILLING_SPEED = 70;
var CLASSIC_GAMERETRY_SPEED = 2100;
var CLASSIC_GAMEDEAD = false;

function initClassicGame() { 
	var canvas = document.getElementById('canvas-classic-game');
	canvas.setAttribute('width', '550');
	canvas.setAttribute('height', '550');
	if (canvas.getContext) { 
		CLASSIC_GAMECANVAS_CONTEXT = canvas.getContext('2d');
	}
}
function resetClassicGame() { 
	stopClassicGame();

	CLASSIC_GAMEDIRECTION = 3;
	CLASSIC_GAMEDIRECTION_TRY = -1;
	CLASSIC_GAMEDIRECTION_TRY_TIMER = null;
	CLASSIC_GAMEPOSITION_X = 276;
	CLASSIC_GAMEPOSITION_Y = 416;
	CLASSIC_GAMEMOUNTH_STATE = 3;
	CLASSIC_GAMEMOVING = false;
	CLASSIC_GAMEMOVING_TIMER = -1;
	CLASSIC_GAMEKILLING_TIMER = -1;
	CLASSIC_GAMEDEAD = false;
	CLASSIC_GAMESUPER = false;
}
function getClassicGameCanevasContext() { 
	return CLASSIC_GAMECANVAS_CONTEXT;
}

function stopClassicGame() { 
	if (CLASSIC_GAMEMOVING_TIMER != -1) { 
		clearInterval(CLASSIC_GAMEMOVING_TIMER);
		CLASSIC_GAMEMOVING_TIMER = -1;
		CLASSIC_GAMEMOVING = false;
	}
	if (CLASSIC_GAMEKILLING_TIMER != -1) { 
		clearInterval(CLASSIC_GAMEKILLING_TIMER);
		CLASSIC_GAMEKILLING_TIMER = -1;
	}
}

function pauseClassicGame() { 
	if (CLASSIC_GAMEDIRECTION_TRY_TIMER != null) { 
		CLASSIC_GAMEDIRECTION_TRY_TIMER.pause();
	}
	
	if ( CLASSIC_GAMEMOVING_TIMER != -1 ) { 
		clearInterval(CLASSIC_GAMEMOVING_TIMER);
		CLASSIC_GAMEMOVING_TIMER = -1;
		CLASSIC_GAMEMOVING = false;
	}
}
function resumeClassicGame() { 
	if (CLASSIC_GAMEDIRECTION_TRY_TIMER != null) { 
		CLASSIC_GAMEDIRECTION_TRY_TIMER.resume();
	}
	moveClassicGame();
}

function tryMoveClassicGameCancel() { 
	if (CLASSIC_GAMEDIRECTION_TRY_TIMER != null) { 
		CLASSIC_GAMEDIRECTION_TRY_TIMER.cancel();
		CLASSIC_GAMEDIRECTION_TRY = -1;
		CLASSIC_GAMEDIRECTION_TRY_TIMER = null;
	}
}
function tryMoveClassicGame(direction) { 
	CLASSIC_GAMEDIRECTION_TRY = direction;
	CLASSIC_GAMEDIRECTION_TRY_TIMER = new Timer('tryMoveClassicGameCancel()', CLASSIC_GAMEDIRECTION_TRY_CANCEL);
}

function moveClassicGame(direction) {

	if (CLASSIC_GAMEMOVING === false) { 
		CLASSIC_GAMEMOVING = true;
		drawClassicGame();
		CLASSIC_GAMEMOVING_TIMER = setInterval('moveClassicGame()', CLASSIC_GAMEMOVING_SPEED);
	}
	
	var directionTry = direction;
	var quarterChangeDirection = false;
	
	if (!directionTry && CLASSIC_GAMEDIRECTION_TRY != -1) { 
		directionTry = CLASSIC_GAMEDIRECTION_TRY;
	}
	
	if ((!directionTry || CLASSIC_GAMEDIRECTION !== directionTry)) { 
	
		if (directionTry) { 
			if (canMoveClassicGame(directionTry)) { 
				if (CLASSIC_GAMEDIRECTION + 1 === directionTry || CLASSIC_GAMEDIRECTION - 1 === directionTry || CLASSIC_GAMEDIRECTION + 1 === directionTry || (CLASSIC_GAMEDIRECTION === 4 && directionTry === 1) || (CLASSIC_GAMEDIRECTION === 1 && directionTry === 4) ) { 
					quarterChangeDirection = true;
				}
				CLASSIC_GAMEDIRECTION = directionTry;
				tryMoveClassicGameCancel();
			} else { 
				if (directionTry !== CLASSIC_GAMEDIRECTION_TRY) { 
					tryMoveClassicGameCancel();
				}
				if (CLASSIC_GAMEDIRECTION_TRY === -1) { 
					tryMoveClassicGame(directionTry);
				}
			}
		}

		if (canMoveClassicGame(CLASSIC_GAMEDIRECTION)) { 
			eraseClassicGame();
			
			if (CLASSIC_GAMEMOUNTH_STATE < CLASSIC_GAMEMOUNTH_STATE_MAX) { 
				CLASSIC_GAMEMOUNTH_STATE ++; 
			} else { 
				CLASSIC_GAMEMOUNTH_STATE = 0; 
			}
						
			var speedUp = 0;
			if (quarterChangeDirection) { 
				speedUp = 6;
			}
			
			if ( CLASSIC_GAMEDIRECTION === 1 ) { 
				CLASSIC_GAMEPOSITION_X += CLASSIC_GAMEPOSITION_STEP + speedUp;
			} else if ( CLASSIC_GAMEDIRECTION === 2 ) { 
				CLASSIC_GAMEPOSITION_Y += CLASSIC_GAMEPOSITION_STEP + speedUp;
			} else if ( CLASSIC_GAMEDIRECTION === 3 ) { 
				CLASSIC_GAMEPOSITION_X -= CLASSIC_GAMEPOSITION_STEP + speedUp;
			} else if ( CLASSIC_GAMEDIRECTION === 4 ) { 
				CLASSIC_GAMEPOSITION_Y -= (CLASSIC_GAMEPOSITION_STEP + speedUp);
			}
			
			if ( CLASSIC_GAMEPOSITION_X === 2 && CLASSIC_GAMEPOSITION_Y === 258 ) { 
				CLASSIC_GAMEPOSITION_X = 548;
				CLASSIC_GAMEPOSITION_Y = 258;
			} else if ( CLASSIC_GAMEPOSITION_X === 548 && CLASSIC_GAMEPOSITION_Y === 258 ) { 
				CLASSIC_GAMEPOSITION_X = 2;
				CLASSIC_GAMEPOSITION_Y = 258;
			}
			
			drawClassicGame();
			
			if ((CLASSIC_GAMEMOUNTH_STATE) === 0 || (CLASSIC_GAMEMOUNTH_STATE) === 3) { 
				testBubblesClassicGame();
				testGhostsClassicGame();
				testFruitsClassicGame();
			}
		} else { 
			stopClassicGame();
		}
	} else if (direction && CLASSIC_GAMEDIRECTION === direction) { 
		tryMoveClassicGameCancel();
	}
}

function canMoveClassicGame(direction) { 
	
	var positionX = CLASSIC_GAMEPOSITION_X;
	var positionY = CLASSIC_GAMEPOSITION_Y;
	
	if (positionX === 276 && positionY === 204 && direction === 2) return false;
	
	if ( direction === 1 ) { 
		positionX += CLASSIC_GAMEPOSITION_STEP;
	} else if ( direction === 2 ) { 
		positionY += CLASSIC_GAMEPOSITION_STEP;
	} else if ( direction === 3 ) { 
		positionX -= CLASSIC_GAMEPOSITION_STEP;
	} else if ( direction === 4 ) { 
		positionY -= CLASSIC_GAMEPOSITION_STEP;
	}
	
	for (var i = 0, imax = PATHS.length; i < imax; i ++) { 
	
		var p = PATHS[i];
		var c = p.split("-");
		var cx = c[0].split(",");
		var cy = c[1].split(",");
	
		var startX = cx[0];
		var startY = cx[1];
		var endX = cy[0];
		var endY = cy[1];

		if (positionX >= startX && positionX <= endX && positionY >= startY && positionY <= endY) { 
			return true;
		}
	}
	
	return false;
}

function drawClassicGame() { 

	var ctx = getClassicGameCanevasContext();
	
	ctx.fillStyle = "#fff200";
	ctx.beginPath();
	
	var startAngle = 0;
	var endAngle = 2 * Math.PI;
	var lineToX = CLASSIC_GAMEPOSITION_X;
	var lineToY = CLASSIC_GAMEPOSITION_Y;
	if (CLASSIC_GAMEDIRECTION === 1) { 
		startAngle = (0.35 - (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		endAngle = (1.65 + (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		lineToX -= 8;
	} else if (CLASSIC_GAMEDIRECTION === 2) { 
		startAngle = (0.85 - (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		endAngle = (0.15 + (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		lineToY -= 8;
	} else if (CLASSIC_GAMEDIRECTION === 3) { 
		startAngle = (1.35 - (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		endAngle = (0.65 + (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		lineToX += 8;
	} else if (CLASSIC_GAMEDIRECTION === 4) { 
		startAngle = (1.85 - (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		endAngle = (1.15 + (CLASSIC_GAMEMOUNTH_STATE * 0.05)) * Math.PI;
		lineToY += 8;
	}
	ctx.arc(CLASSIC_GAMEPOSITION_X, CLASSIC_GAMEPOSITION_Y, CLASSIC_GAMESIZE, startAngle, endAngle, false);
	ctx.lineTo(lineToX, lineToY);
	ctx.fill();
	ctx.closePath();
}

function eraseClassicGame() { 

	var ctx = getClassicGameCanevasContext();
	ctx.clearRect( (CLASSIC_GAMEPOSITION_X - 2) - CLASSIC_GAMESIZE, (CLASSIC_GAMEPOSITION_Y - 2) - CLASSIC_GAMESIZE, (CLASSIC_GAMESIZE * 2) + 5, (CLASSIC_GAMESIZE * 2) + 5);
}

function killClassicGame() { 
	playDieSound();

	LOCK = true;
	CLASSIC_GAMEDEAD = true;
	stopClassicGame();
	stopGhosts();
	pauseTimes();
	stopBlinkSuperBubbles();
	CLASSIC_GAMEKILLING_TIMER = setInterval('killingClassicGame()', CLASSIC_GAMEKILLING_SPEED);
}
function killingClassicGame() { 
	if (CLASSIC_GAMEMOUNTH_STATE > -12) { 
		eraseClassicGame();
		CLASSIC_GAMEMOUNTH_STATE --;
		drawClassicGame();
	} else { 
		clearInterval(CLASSIC_GAMEKILLING_TIMER);
		CLASSIC_GAMEKILLING_TIMER = -1;
		eraseClassicGame();
		if (LIFES > 0) { 
			lifes(-1);
			setTimeout('retry()', (CLASSIC_GAMERETRY_SPEED));
		} else { 
			gameover();
		}
	}
}

function testGhostsClassicGame() { 
	testGhostClassicGame('blinky');
	testGhostClassicGame('pinky');
	testGhostClassicGame('inky');
	testGhostClassicGame('clyde');

}
function testGhostClassicGame(ghost) { 
	eval('var positionX = GHOST_' + ghost.toUpperCase() + '_POSITION_X');
	eval('var positionY = GHOST_' + ghost.toUpperCase() + '_POSITION_Y');
		
	if (positionX <= CLASSIC_GAMEPOSITION_X + CLASSIC_GAMEGHOST_GAP && positionX >= CLASSIC_GAMEPOSITION_X - CLASSIC_GAMEGHOST_GAP && positionY <= CLASSIC_GAMEPOSITION_Y + CLASSIC_GAMEGHOST_GAP && positionY >= CLASSIC_GAMEPOSITION_Y - CLASSIC_GAMEGHOST_GAP ) { 
		eval('var state = GHOST_' + ghost.toUpperCase() + '_STATE');
		if (state === 0) { 
			killClassicGame();
		} else if (state === 1) { 
			startEatGhost(ghost);
		}
	}
}
function testFruitsClassicGame() { 
	
	if (FRUIT_CANCEL_TIMER != null) { 
		if (FRUITS_POSITION_X <= CLASSIC_GAMEPOSITION_X + CLASSIC_GAMEFRUITS_GAP && FRUITS_POSITION_X >= CLASSIC_GAMEPOSITION_X - CLASSIC_GAMEFRUITS_GAP && FRUITS_POSITION_Y <= CLASSIC_GAMEPOSITION_Y + CLASSIC_GAMEFRUITS_GAP && FRUITS_POSITION_Y >= CLASSIC_GAMEPOSITION_Y - CLASSIC_GAMEFRUITS_GAP ) { 
			eatFruit();
		}
	}
}
function testBubblesClassicGame() { 
	
	var r = { x: CLASSIC_GAMEPOSITION_X - ( CLASSIC_GAMESIZE / 2 ), y: CLASSIC_GAMEPOSITION_Y - ( CLASSIC_GAMESIZE / 2 ) , width: ( CLASSIC_GAMESIZE * 2 ), height: ( CLASSIC_GAMESIZE * 2 ) };
		
	for (var i = 0, imax = BUBBLES_ARRAY.length; i < imax; i ++) { 
		var bubble = BUBBLES_ARRAY[i];
		
		var bubbleParams = bubble.split( ";" );
		var testX = parseInt(bubbleParams[0].split( "," )[0]);
		var testY = parseInt(bubbleParams[0].split( "," )[1]);
		var p = { x: testX, y: testY };
		
		if ( isPointInRect( p, r ) ) { 
			
			if ( bubbleParams[4] === "0" ) { 
				var type = bubbleParams[3];
							
				eraseBubble( type, testX, testY );
				BUBBLES_ARRAY[i] = bubble.substr( 0, bubble.length - 1 ) + "1"
				
				if ( type === "s" ) { 
					setSuperBubbleOnXY( testX, testY, "1" );
					score( SCORE_SUPER_BUBBLE );
					playEatPillSound();
					affraidGhosts();
				} else { 
					score( SCORE_BUBBLE );
					playEatingSound();
				}
				BUBBLES_COUNTER --;
				if ( BUBBLES_COUNTER === 0 ) { 
					win();
				}
			} else { 
				stopEatingSound();
			}
			return;
		}
	}
}