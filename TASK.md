# Build a TicTacToe Game

**Note**: Please have a full read through of this exercise end to end, and please do raise questions before you begin!

Developing frontend experiences that are a joy to use across devices
is a vital part of web development and a craft on its own. 
Realtime Collaboration is also a key feature in modern web applications, 
and Elixir/Phoenix provide building blocks to achieve that rather easily.

Coordinating parallel interactions in the backend to power it all, as well as
provide snappy computed responses is also an engineering feat. 
Especially ensuring a bottleneck-free architecture on critical code paths is
a must nowadays, when there are unexpected traffic bursts of 10k+ people hitting
different parts of the application.

We would like you to architect, engineer and beautify a small app where users can
play TicTacToe against a computer opponent or each other. Additionally, we want to 
have a "spectator mode", where other (anonymous) users can join a running match, 
including realtime commentary (think: twitch).

This project should take no longer than 4 hours from concept to production if you 
know the techstack reasonably well. 

## Prerequisites

Before starting the exercise, you should have the following completed:

- Installed Elixir (latest version should be fine).
- PostgreSQL (if needed, latest version should be fine).
- A github account that can create public repositories.

## Before you start

- Your submission should not include code that you do not own (open source code is allowed).
  **This will result in immediate disqualification.**
- It is not required to submit a deployed endpoint, but some _proof of correctness_
  will be needed.

## Objective 1: The Functionality

Design a LiveView-Application using that renders a
[TicTacToe](https://en.wikipedia.org/wiki/Tic-tac-toe) grid. Players can click on
empty cells to make their move, the computer (or another player)
will immediately make his turn afterwards, and the new state should be displayed.

Rules:

- The human player always makes the first move, in multiplayer setups (visually) randomize who begins.
- Once there is a winner, highlight the winning row and show a proper congratulations message.
- If there is a tie, also show a proper message for that.
- At all times, there is a button to (re-)start the game from scratch
- when starting a new game, there is an option to choose from: against the computer or against a human
- if its against a human, present a shareable URL to join the game, but ensure that there never are more than 2 **players**

Since this exercise focusses on the visualizations and game experiences, feel free
to use [well-known algorithms](https://www.freecodecamp.org/news/how-to-make-your-tic-tac-toe-game-unbeatable-by-using-the-minimax-algorithm-9d690bad4b37/)
to implement the "this is the next move from the computer player" task. There
are also [hex packages](https://hex.pm/packages?search=tic+tac+toe&sort=recent_downloads) you might use.

Technology:

- The solution must be implemented using Elixir, Phoenix 1.7+, LiveView and TailwindCSS
- ensure that functions have proper `@doc`/`@spec` attributes and unittests
- ensure that a crash in the current game does not crash the LiveView process

## Objective 2: The User Interface

The app should look visually appealing on phones, tablets as well as desktops.
Take care especially on clients that are _not_ derived from chrome, such as
firefox. Ensure that touch-based inputs work as well as mouse-based inputs and
vice versa. Structure everything into proper (Live-)Components and tame the
TailwindCSS into manageable chunks. 

## Objective 3: The User Experience

The app/game should be fun to play.

- to ensure that no flaws happen, write automated tests that ensure playing games is indeed possible.
- the first impression should be great (loads+renders instantly, no cascade of reflows, no waiting for google fonts, ...)
- try to make the "one more game" experience smooth and addicting (ie: animations, winning streak counter, ...)
- bonus 1: make a "demo" where two GenServer/Agent processes act as computer players who (with a random first move) 
  play against each other continuously, that can be put on the index/home page, to make people try the game initially.
- bonus 2: try to use an AI (like ChatGPT API) so produce commentary about how the game goes to cheer up players and/or spectators in realtime.

## Submission

We expect you to submit/link a dedicated github repository containing the
code and a concise README so _other developers_ can pick up the
ball easily in case more features are needed. Link to a properly deployed
version of your code is a big plus.