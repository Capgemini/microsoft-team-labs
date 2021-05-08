'use strict';

const fs = require('fs');
const PluginError = require('plugin-error');
const through = require('through2');

const PLUGIN_NAME = 'document-relative';

let count = 0;

module.exports = function (options) {

  // Remove slashes from beginning and end of string
  const strip_slashes = (string) => {
    return string ? string.replace(/^\/|\/$/g, '') : null;
  }

  // Users options object
  options = options || {};

  // Cleanup options
  const base_dir = strip_slashes(options.directory);
  const url = strip_slashes(options.url) + '/';

  return through({
    objectMode: true,
    writable: true,
    readable: true
  },
    function (file, enc, callback) {
      count++;

      // Check for null file
      if (file.isNull()) {
        return callback(null, file);
      }

      if (file.isStream()) {
        this.emit('error', new PluginError(PLUGIN_NAME, 'Stream not supported!'));
        return callback(null, file);
      }

      if (file.isBuffer()) {

        // Get contents of this file
        let html = file.contents.toString(enc);

        // This files full path (/home/usr/project/build/page/example/index.html)
        const path = file.path;

        // Path task was run from (/home/usr/project/)
        const cwd = file.cwd + (base_dir ? '/' + base_dir : '');

        // Project specific path (/page/example/index.html)
        const relative = path.replace(cwd, '');

        // Get array of directories ['page', 'example', 'index.html']
        let paths = strip_slashes(relative).split('/');

        // Remove last item ['page', 'example']
        paths.pop();

        // Add ../ for nth number of paths in array
        let rel_path = paths.length === 0 ? '' : ('../'.repeat(paths.length));

        // Replace dom attributes (e.g. href="/page/example")
        html = html.replace(/(?:(?!="\/\/)="\/)/g, '="' + rel_path);

        // Replace inline background (e.g. background: url('/image/something.jpg'))
        html = html.replace(/url\(\'\//g, 'url(\'' + rel_path);
        html = html.replace(/url\(&#039;\//g, 'url(&#039;' + rel_path);

        // If user defined URL, match and remove
        if (url && url.length) {
          html = html.replace(new RegExp(url, 'g'), rel_path);
        }

        // Overwrite file
        fs.writeFileSync(file.path, html, {
          encoding: enc,
          flag: 'w'
        });

        return callback();
      }
    });
};