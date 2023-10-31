# TicTacToe Project

This app is called Tic. It implements multiplayer Tic Tac Toe game, with simplistic AI or against another user.

User must register and login to play. While anonymous user can only watch the game.
There is a chat function within the game, where everyone can send message and comment in the game.

## Building and Running the Project

In order to build and run this project, you need a working *Elixir* environment.
You can follow the [Installing Elixir](https://elixir-lang.org/install.html)
guide to get *Elixir* running in your system.

The minimum version required by this project is defined in the
[mix.exs](mix.exs) file.

### Running the Project

When you have the required elixir environment working, running this project is
pretty straightforward.

``bash
$ mix deps.get
$ mix ecto.setup
$ mix phx.server
``

Then go to "http://localhost:4000" to view the app.



