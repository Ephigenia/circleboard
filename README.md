Circleboard

Circleboard is a dashboard which displays the latest builds of projects automatically tested on [CircleCi](https://circleci.com/). It is designed to be leightweight and easy to install.

It’s based on a server written in node which periodically requests the circleci status api using a status api key and sends the results to the frontend over a opened socket.io connection. The frontend which is written in pure javascript will then update the build status views.

## Demo

There’s demo of the circle ci status board running on heroku: [http://circleboard.herokuapp.com/](http://circleboard.herokuapp.com/)

<img src="https://raw.github.com/foobugs/circleboard/master/screenshot.jpg" alt="demo screenshot" />

## Setup

Clone the project and run `npm install` which will download dependencies and create a first build of the web project.

After that you need to tell the server which projects you want to display on the dashboard by copying the `config.dist.coffee` file to `config.coffee` and modify it. Go to the [API Tokens Page in the Circle CI Settings](https://circleci.com/account/api) to create your api-key.

After that you only need to run the server with `coffee server.coffee` and open the browser.

Description in code:

	npm install
	cp config.dist.coffee config.coffee
	$EDITOR config.coffee
	coffee server.coffee
	o localhost:50000

## Circle CI Api Key

The Api Key can be stored in the configuration. If there’s no key found in the configuration a key is searched in the ENV variable `CIRCLE_CI_API_KEY`.
