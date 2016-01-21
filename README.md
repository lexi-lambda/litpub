# LitPub

LitPub is a tiny webapp for publishing stories (or any other sort of writing, really) with beautiful typography. Stories can be viewed and voted on, and users can submit feedback. Currently, that’s about it. Consider it something of a self-hosted “mini Medium”.

## Installation

### Prerequisites

- [Racket][racket]
- [PostgreSQL][postgres]

### Installing the project

This repository can be installed as a Racket package. Simply navigate into the project folder, and run:

```
$ raco pkg install
```

Alternatively, provide the project path directly:

```
$ raco pkg install path/to/litpub
```

You will likely be prompted to install extra dependencies that you do not have—simply affirm the installation of those extra packages, and everything will be installed.

### Setting up the database

LitPub runs by interacting with a PostgreSQL database. You will need to create a database and run the migrations in the `db/migrations/` folder. Currently there is no automated mechanism for running all migrations, so just run each one in order (they are timestamped).

## Running the Server

LitPub is implemented using the Racket webserver, and it uses environment variables for server configuration. You will need to set the following environment variables in order for the server to run:

  - `PORT` — The port that the server will bind to.
  - `DATABASE_URL` — A PostgreSQL connection url with the following form:

     ```
     postgres://user[:password]@host:port/database_name
     ```

With these environment variables set, the server can be run with the following command:

```
$ racket -l litpub
```

You can then navigate your browser to the chosen port to see the server in action, although you likely won’t see much until you have some data in the database.

## Creating Stories

Stories are written in Markdown and stored in the `stories` table in the database. All stories have three fields: a `title`, a `body`, and whether or not they are a `draft`. Stories also have `created_at` and `updated_at` fields. These will be initialized to the current time automatically upon creation, but since there is no UI to edit stories right now, you will need to updated `updated_at` manually if you edit stories (it is not enforced by a DB trigger).

Stories stored in the database will be displayed on the home page, segregated into sections for completed stories and drafts. This distinction is currently fairly arbitrary, but it might be more meaningful in the future.

## Features

  - The primary feature, of course, is *stories*. These can be written, browsed, and (hopefully) read! Each story gets its own page almost entirely to itself, with as little clutter as possible.

  - Part of the purpose of this project is an attempt to make writing look beautiful with minimal effort. In addition to the simple fonts used by the project, as well as converting straight quotes to curly quotes and similar enhancements in the markdown parser, LitPub goes a bit further by automatically detecting and “hanging” leading quotation marks. You can see this if you start a paragraph with an open double quote character.

  - Stories are identified by a pretty URL that includes a “slugified” version of the title. This keeps URLs looking clean an meaningful, but don’t worry: you can still change the title at any time. If the slug in the URL doesn’t match, you’ll be automatically redirected to use an up-to-date slug.

  - Users may vote on stories by clicking the small heart at the bottom of each story’s page. Stories may not be voted down, only voted up—given that there are no objective metrics for story quality, it makes little sense to have an ability to express that one didn’t like something.

  - There are currently no comments, but users can give free-form feedback at any time by clicking the “Feedback” link in the corner. Feedback submitted in this way will be stored in the `user_feedback` database table; no notification or email is dispatched at this time.

## Internals

The whole system is mostly driven by the architecture of the [Racket web server][web-server]. It is architectured as a single-servlet server using the built-in dispatcher for routing. A number of design choices fell out of this decision:

  - The server itself boots through `main.rkt`, which handles linking everything together.
  - The router is contained in `route-unit.rkt`, which implements the entire dispatcher.
  - All the route handlers are included under the `handler/` directory.

### Late-binding of handlers

One important thing to note is that these modules may all need to cross-reference each other. This is because of how the Racket dispatcher works: it allows generation of URLs based on handler functions themselves. This is incredibly useful, since it helps to add a layer of “safety” to URLs, as well as just making them more convenient to use, but it also means that modules will need to be arranged in circular references, which Racket does not really support.

To accommodate this, the router and all handler modules are implemented as [Racket units][units], which use a form of late binding, so they can be linked at runtime to permit circular references.

### Configuration

Configuration is managed through the environment via the [envy][envy] package. The `environment.rkt` module describes the environment needed, and it is required into other modules, generally using `prefix-in` to create a namespace.

### Data model

Racket has no ORM, so query helpers are manually implemented in `model.rkt` (fortunately, the model is small). Currently, it just uses inline SQL, all contained within a single file, but it might need to be split up if the model grows.

### Templating

All templating is done using [X-expressions][xexprs], a way to represent XML and XML-like languages using S-expressions. The boilerplate is included in `template.rkt`, which contains the global page template; the remainder of pages are templated within their individual handler functions.

Additionally, the `util/xexpr.rkt` and `util/jsexpr.rkt` modules provide helpers for producing responses. The `xexpr.rkt` module includes functions for preprocessing X-expressions to parse markdown, hang open quotes, and insert soft hyphens for hyphenation. The `jsexpr.rkt` module simply provides a helper for creating JSON responses, in the style of the built-in `response/xexpr`.

### Assets

Assets are automatically served out of the `public/` directory. The Racket web server does *not* implement any sort of caching out of the box, so it is recommended that you run a reverse proxy such as Apache or Nginx in front of it in production in order to cache static assets (or serve assets through a CDN, avoiding serving assets yourself entirely).

Currently, the primary assets included are fonts, which are *not* licensed for reuse. If you would like them, they were created by [Matthew Butterick][mbutterick] and are available for purchase.

The other assets are scripts and styles, both of which are fairly simple. To avoid the need for any kind of build system, both are implemented in plain JS and CSS, respectively, all in single files. Eventually, this might cease to scale, but it works for now. The CSS is mostly self-explanatory, and the JS is only to implement the voting feature on story pages.

[envy]: http://pkg-build.racket-lang.org/doc/envy/index.html
[mbutterick]: http://practicaltypography.com
[racket]: http://racket-lang.org
[postgres]: http://www.postgresql.org
[units]: http://docs.racket-lang.org/guide/units.html
[xexprs]: http://docs.racket-lang.org/xml/index.html
[web-server]: http://docs.racket-lang.org/web-server/index.html
