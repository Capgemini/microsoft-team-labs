# Codelabs Site

A site for hosting codelabs content.


## Prerequisites

The project requires the following major dependencies:

- [Go](https://golang.org/dl/) language
- [Node.js](https://nodejs.org/en/download/) v10+ and [npm](https://www.npmjs.com/get-npm)
- [claat](https://github.com/googlecodelabs/tools/tree/master/claat#install)

With Node installed, run `npm install` in the root of the repo:

```text
$ npm install
```

(Optional) npm installs binstubs at `./node_modules/.bin/`. When running tasks
like `gulp`, you may want to add `./node_modules/.bin/` to your `$PATH` for convenience:

```text
$ export PATH="./node_modules/.bin/:$PATH"
```

This does pose a mild security risk, so please do so at your own risk.


## Development

### Serve

To serve the site in dev mode, run `npm run serve`, passing a path to a directory
with the codelabs content as an argument. This will compile all the views and
codelabs into the `build/` directory and start a web server to serve that
content. Additionally, all files will be watched and the site will rebuild when they change. 

The output will include the address where the server is running
(http://localhost:8000 by default).

You can also serve the completely compiled and minified (prod) version with the
`npm run serve:dist` command. Always run this before publishing, as it will show you an
replica of what will appear on staging/production.

#### Error: EPERM: operation not permitted, symlink '..' -> 'build\codelabs'

This must be run under an admin terminal.

#### Error: Tables aren't correctly formatted

Change the End of Line Sequence from `CRLF` to `LF`. 

### Views

Views are themed/styled collections of codelabs, served from the same url.
Codelab tags are used for selecting codelabs into views. View definitions are
stored in `/app/views` directory. Views commonly correspond to events (e.g. NEXT
2018) or abstract themes (e.g. Windows), but we refer to them generically as
"views" internally.

#### Add a new view

To add a new view (e.g. to serve codelabs for a particular event):

1. Create a new folder in `app/views`, which will be the "view id". As the view
id will appear in the URL, the name should be sluggified, meaning all lowercase
with special characters replaced with dashes.

    ```text
    // General example
    My Codelab -> my-codelab

    // Always substitute file extensions, otherwise the browser will get confused
    Learn underscore.js -> learn-underscore-js

    // Keep other URL-friendly characters when the context warrants
    Tracking with utm_source -> tracking-with-utm_source
    ```

1. Add a new file named `view.json` inside this folder. Here is a template
`view.json`:

    ```javascript
    // app/views/my-event/view.json
    {
      // Required: page and view title.
      "title": "My Event",

      // Required: Text description of the event. This will appear in the view
      // landing page.
      "description": "",

      // Required: list of string tags by which to include codelabs. Tags are
      // specified in the codelab by the codelab author.
      "tags": [],

      // Optional: list of string categories by which to include codelabs.
      // Categories are specified in the codelab by the codelab author.
      "categories": [],

      // Optional: name of a custom stylesheet to include. See also: point below
      // about custom styles.
      "customStyle": "style.css",

      // Optional: list of regular expressions to exclude particular codelabs.
      "exclude": [],

      // Optional: URL to a custom logo for the codelab. If provided, this logo
      // must be placed in app/views/<view-id>/ and referenced as such. For
      // example, if the event was named "my-event", this logo would exist at
      // app/views/my-event/my-event-logo.svg.
      //
      // Where possible, please use SVG logos. When SVG logos are not available,
      // please size images to be 125px high at 72 DPI.
      //
      // Minify images before uploading using a tool like ImageOptim.
      "logoUrl": "/my-event/my-event-logo.svg",

      // Optional: category level to use for iconography
      "catLevel": 0,

      // Optional: Method for sorting codelabs.
      "sort": "mainCategory",

      // Optional: List of codelab IDs that should be "pinned" at the start.
      // This is useful for "getting started" codelabs or when users should
      // complete codelabs in a specific order.
      "pins": [],

      // Optional: custom google analytics tracking code. By default, all
      // codelab views are tracked on the main codelab analytics.
      "ga": "",

      // Optional: If true, do not include this view in the list of views on
      // the home page. It will still be accessible via the direct URL.
      "hidden": false,
    }
    ```

1. (Optional) Add a file named `style.css` inside the view folder. If provided,
this file will be included in the HTML, allowing for custom styles.

    This file is not included in the main assets bundle, so there will be a
    performance decrease as the browser needs to load additional styles.
    Furthermore, if the codelab schema were to change, your custom styles may be
    broken. Please check with the codelabs team to see if your style changes
    make more sense to upstream across all views.

1. (Optional) Add a file named `index.html` inside the view folder. This allows
you to fully customize the view, but comes at the expense of duplication. Please
use this sparingly and check with the core team before making drastic changes.

1. Execute the `serve` command as described above to see the view.


## Options

`--base-url` - base URL for serving canonical links. This should always include
the protocol (http:// or https://) and NOT including a trailing slash. The
default value is "https://codelabs.developers.google.com".

`--codelabs-dir` - absolute or relative path on disk where codelabs are stored.
Any filters will be applied to these codelabs, and then the resulting selection
is symlinked into the build folder. The default value is "." (the current directory).

`--codelabs-filter` - regular expression by which to filter codelabs IDs for
inclusion. If a filter is not specified, all codelabs are included.

`--codelabs-namespace` - URL path where codelabs will be served in the web
server. The default value is "/codelabs", meaning codelabs will be served at
https://URL/codelabs.

`--views-filter` - regular expression by which to filter included views
(events). If a filter is not specified, all views are included.

The following options are only relevant when invoking claat:

`--codelabs-env` - environment for which to build codelabs. The default value is
"web".

`--codelabs-format` - format in which to build the codelabs. The default value
is "html"

`--codelab-source` - Google Doc ID from which to build codelab. This can be
specified multiple times to build from multiple sources.


## Testing

To run the tests manually in a browser, execute the following:

```text
$ gulp serve
$ open http://localhost:8000/app/js/all_tests.html
```


## Help

For help documentation/usage of the Gulp tasks, run:

```text
$ gulp -T
```

If gulp startup times are really slow, try removing `node_modules/` or running

```text
$ npm dedupe
```
