fs = require 'fs'
styl = require 'styl'
rework_calc = require 'rework-calc'
rework_color = require 'rework-color-function'
rework_colors = require 'rework-plugin-colors'
rework_inherit = require 'rework-inherit'
rework_variant = require 'rework-variant'
rework_function = require 'rework-plugin-function'
rework_import = require 'rework-import'

VERBOSE = process.env.METASERVE_VERBOSE?

# Reduce timestamp resolution from ms to s for last-modified
de_res = (n) -> Math.floor(n/1000)*1000

module.exports =
    ext: 'sass'

    default_config:
        content_type: 'text/css'

    compile: (filename, config, context, cb) ->
        console.log '[StylCompiler.compile]', filename, config if VERBOSE

        variant = rework_variant(context)
        pre_transformer = (sass_src) ->
            styl(sass_src, {whitespace: true})
                .use(rework_import({path: config.base_dir + '/css', transform: pre_transformer}))
                .toString()

        transformer = (sass_src) ->
            styl(pre_transformer(sass_src))
                .use(rework_inherit()) # `inherit: selector`
                .use(variant) # For variable replacement
                .use(rework_calc) # `calc(x + y)`
                .use(rework_colors()) # `rgba(#xxx, 0.x)` transformers
                .use(rework_color) # color tint functions
                .use(rework_function(config.functions || {})) # For functions
                .toString()

        # Read and compile source
        source = fs.readFileSync(filename).toString()
        compiled = transformer source
        cb null, {
            content_type: config.content_type
            source
            compiled
        }

