// Generated by CoffeeScript 1.12.4
var VERBOSE, autoprefixer, de_res, fs, rework_calc, rework_color, rework_colors, rework_function, rework_import, rework_inherit, rework_variant, styl;

fs = require('fs');

styl = require('styl');

rework_calc = require('rework-calc');

rework_color = require('rework-color-function');

rework_colors = require('rework-plugin-colors');

rework_inherit = require('rework-inherit');

rework_variant = require('rework-variant');

rework_function = require('rework-plugin-function');

rework_import = require('rework-import');

autoprefixer = require('autoprefixer');

VERBOSE = process.env.METASERVE_VERBOSE != null;

de_res = function(n) {
  return Math.floor(n / 1000) * 1000;
};

module.exports = {
  ext: 'sass',
  default_config: {
    content_type: 'text/css'
  },
  compile: function(filename, config, context, cb) {
    var compiled, pre_transformer, source, transformer, variant;
    if (VERBOSE) {
      console.log('[StylCompiler.compile]', filename, config);
    }
    variant = rework_variant(context);
    pre_transformer = function(sass_src) {
      return styl(sass_src, {
        whitespace: true
      }).use(rework_import({
        path: config.static_dir + '/css',
        transform: pre_transformer
      })).toString();
    };
    transformer = function(sass_src) {
      var css;
      css = styl(pre_transformer(sass_src)).use(rework_inherit()).use(variant).use(rework_calc).use(rework_colors()).use(rework_color).use(rework_function(config.functions || {})).toString();
      return css = autoprefixer.process(css).css;
    };
    source = fs.readFileSync(filename).toString();
    compiled = transformer(source);
    return cb(null, {
      content_type: config.content_type,
      source: source,
      compiled: compiled
    });
  }
};
