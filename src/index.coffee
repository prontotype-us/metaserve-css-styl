fs = require 'fs'
styl = require 'styl'
rework_calc = require 'rework-calc'
rework_color = require 'rework-color-function'
rework_colors = require 'rework-plugin-colors'
rework_inherit = require 'rework-inherit'
rework_variant = require 'rework-variant'
rework_function = require 'rework-plugin-function'
rework_shade = require 'rework-shade'
rework_import = require 'rework-import'
Compiler = require 'metaserve/lib/compiler'

# Reduce timestamp resolution from ms to s for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

class StylCompiler extends Compiler

    default_options:
        import_dir: './static/css'
        ext: 'sass'
        vars: {}

    compile: (sass_filename, cb) ->
        options = @options

        variant = rework_variant(options.vars)
        pre_transformer = (sass_src) ->
            styl(sass_src, {whitespace: true})
                .use(rework_import({path: options.import_dir, transform: pre_transformer}))
                .toString()

        transformer = (sass_src) ->
            styl(pre_transformer(sass_src))
                .use(rework_inherit()) # `inherit: selector`
                .use(variant) # For variable replacement
                .use(rework_calc) # `calc(x + y)`
                .use(rework_colors()) # `rgba(#xxx, 0.x)` transformers
                .use(rework_color) # color tint functions
                .use(rework_function(options.functions || {})) # For functions
                .toString()

        # Read and compile source
        source = fs.readFileSync(sass_filename).toString()
        compiled = transformer source
        cb null, {
            content_type: 'text/css'
            source
            compiled
        }

module.exports = (options={}) ->
    new StylCompiler(options)

