# ELI5--
## Description

ELI5-- is an iOS application that parses threads from https://www.reddit.com/r/explainlikeimfive/, simplifies the top explanation, and provides images to supplement it. ELI5-- is my final project for Cal Poly's Mobile Application Development, CSC 436.

ELI5-- utilizes 3 APIs:
* [Reddit](https://www.reddit.com/dev/api)
* [Google Cloud Natural Language](https://cloud.google.com/natural-language/)
* [Google Custom Search](https://developers.google.com/custom-search/)

## CSC 436 Milestone 4 Thoughts
* I was pretty happy with how the table view showing all the threads turned out. Colors look greats
* I'm really happy with how well I documented/commented my source code. My GitHub has a nice paper trail of my work
* Decided to not use Google Cloud Vision API and use Google Cloud Natural Language API as the second moving part and Google Custom Search API as the third
* What I would do next time is change how I extract the keywords to run the search terms. The image search could be better. Use Google Vision API to validate image search
* To take ELI5-- to a level of deployment on the App Store, I would need to implement more features like sorting feeds by category and time. Would also need to put in more time on how it programmatically simplifies and gets pictures
* Ideally, the visualizations would be presented like a mosaic, maybe even interactive visualizations
