# love-update

This program is a simple wrapper to keep a LOVE2D game updated online. It retrieves version data from your server and downloads a new copy of the game if necessary, and starts whatever the most recent version is.

I used this to distribute my [cow emoji game](https://github.com/spencer-p/cow-game) to my friends.

This project was interesting to spin up and get working when I needed it, but it lacks

* https requirements
* code signing
* documentation
* an easy way to launch a new game version without manually editing files

I wrote it because I was circumventing Apple's app store (and update system), and all that stuff exists for good reason. I keep this online as a proof-of-concept and for posterity.
