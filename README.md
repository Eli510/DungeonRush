Credits:

DungeonRush is a game made by me, Eli Shtindler. All of the art used in the game was made by DragonDePlatino. His 16x16 
tileset, Dawnlike, was used to create this game. The color palette used to make the tileset was created by DawnBringer. 
SkyVaultGames' tutorials were a big help in creating many of the features. Some parts of his code were used and modified for 
use in this game.

Download and File Explanation:

After downloading DungeonRush from github, unzip the DungeonRush-master.zip file that you downloaded. Inside of this file there 
should be two folders along with an assortment of other files. The sprites folder contains all of the art used in the game. 
The tables folder has lua files with data that is accessed when main.lua is run. These files do not actually run much code and
just organize data. The other 3 lua files contain the source code for the game. The md files contain documentation for this 
game. The exe and love files can be used to run the game. 

Use:

There are two ways to run the game. The first and easier way is to run the "DungeonRush.exe" file. This can only be done if 
you are on a Windows operating system and can be done by double clicking on the file. The other method requires Love2d to be
installed. Visit love2d.org for links to download it. Once Love2d has been downloaded, you can double click on the
"DungeonRush.love" file to run it. If you are on Mac, you may receive a message that "love.app" is from an unidentified
developer and you will not be allowed to run the program. There are many way to get around this and you can easily find them 
online.

Game Instructions:

Buttons--

	There are two types of clickable buttons, both of which will respond to you hovering over them and clicking them. Normal 
	button become brighter when you have over them and will do what the text on them describes if you click them. Attacks are 
	also clickable buttons, but their behavior changes based on which environment you are in.
	
Map--

	When you first start a game, your character will be located in a map. You can move your character around using the WASD
	keys. Paths the appear to lead out of the room will take you to a different room if you walk over them. Walking in front
	of the character behind the table will open the shop screen.
	
Stats--

	There are 5 main elements visible on the bottom of the screen. On the left there is a pile of coins with a number next to 
	it. This shows your money, which is used to purchase items from the shop. The timer in the center counts down from 5 
	minutes. When it reaches 0, you must fight a difficult boss. The goal of the game is to get strong enough to defeat the 
	boss within 5 minutes. The number next to a skull on the right is the current level of the room. Rooms with higher levels
	have more difficult enemies. The heart with a red bar to the right of it shows your health. The number in the middle of 
	the bar shows how much current health you have out of your max health. If you lose all of your health, you lose the game.
	The letters "EXP" with a bar next to it shows the amount of experience you currently have out of the experience you require
	to level up. Fighting enemies will reward you with experience. Once you get enough experience to level up, you will lose 
	the experience and the amount required to level up again will increase. You will also gain max and current health each time
	you level up.
	
Combat--

	One of the ways to get stronger is by fighting enemies. As you move around the dungeon, there are random enemy fights.
	Moving around more results in more combats. When you enter a combat you will see two characters with red bars underneath 
	them. The character on the left is the player and the character on the right is the enemy. The bars underneath each
	of the characters and the numbers on the bars show how much health the character has out of its maximum. Enemies will 
	constantly do damage to you until you defeat them or run out of health. In the lower half of the screen you can see your
	attacks. Clicking on your attacks while in combat will do damage to the enemy and begin the cooldown on the attack. You
	must wait for the cooldown to finish before you can use the attack again. If you are in a higher level room, enemies will
	become stronger, doing more damage and having more health. Stronger enemies will also give you more experience and coins
	if you defeat them.
	
Shop--

	In the shop, you can purchase more attacks, as well as purchasing health and selling attacks for coins. Clicking on attacks
	while in the shop will purchase them. There are 4 random attacks available at the shop for sale. You can get a new set of 
	4 attacks at the shop at any time by clicking the "Refresh Shop" button. This costs 10 coins to do. You can also sell attacks
	at the shop. If you click on the "Sell Attacks" button you are brought to a screen with all of your current attacks. Clicking
	on an attack while in this screen will sell the attack, removing it from you available attacks and giving you 10 coins. The
	"Buy Health" button allows you to purchase 1 health for two coins. You can only own 1 of each attack.
	
Selecting Attacks--

	While you are on the map screen, you can press "e" to view all of your attacks. Equipped attacks are white, while unequipped
	attacks are gray. Clicking on an attack will toggle it between equipped and unequipped. equipped attacks are usable in combat,
	but only 4 attacks can be equipped at any time.
	
Timer--

	There is a timer that is constantly going down at the bottom of the screen. Once this timer reaches 0, you fight a very
	powerful boss. If you defeat the boss, you win the game. There is no way to stop this timer once you have started a game.
	
Addition Notes--

	Pressing the escape key at any time will bring you back to the home screen. No data will be saved if you return to the home
	screen.
	
	
	
	
	
	
	
	
	
	
	
	
	
	