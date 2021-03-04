# donation-board
Modular, open sourced donation board with a sleek user interface.

### Setup
1. Download the DonationBoard.rbxm file from this repository.
2. Drag the file into Roblox Studio.
3. Create a developer product in your game for each donation amount.
    - <a href="https://developer.roblox.com/en-us/articles/Developer-Products-In-Game-Purchases">Click to learn how to create developer products</a>

### Configuration
> When you insert the file into Roblox Studio, you'll see a folder called "DonationSystem". Inside of that, you'll find a script called "Core". At the top of this script is where all your settings are located.

> If you are experienced with Roblox user interfaces, you can convert the donation list `Frame` into a `ScrollingFrame` to allow for more than five options to be shown.

- The first setting you'll see is `DATA_KEY`. This is the key in which donation data is stored. Changing this will wipe any existing data stored by the donation board.
- The second setting is `GUI_FACE`. This will determine what face of the part the donation board shows on. You can have more than one board, as long as they are all named "Board" and are in the "DonationSystem" folder. 
- The third setting is `DISPLAY_AMOUNT`. This is the amount of players that the leaderboard will display. Note than if you make this value greater than 25, you will need to manually increase the `CanvasSize` of the leaderboard `ScrollingFrame`.
- The fourth setting is `REFRESH_RATE`. This is how often the leaderboard will be refreshed/updated. Keeping this higher than 30 is adviced to not put stress on the server.
- The fifth setting is `DONATION_OPTIONS`. Using the developer products that you made earlier, fill in the amount of robux it costs and the product ID for each option. The board only has room to display five options.

## Warnings
- This board will not work in Roblox Studio unless you have "Enable studio access to API services" enabled under game settings.
- This board will not work in unpublished places.

**You're done! Enjoy your donation board.**

*Report any bugs or issues to **Twin#0727** on discord!*
