_ = require('lodash')

module.exports = (env, callback) ->
  defaults =
    perPage: 2 # number of articles per page
    articles: 'articles' # directory containing contents to paginate

  options = env.config.paginator or {}
  for key, value of defaults
    options[key] ?= defaults[key]


  class IndexPage extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@articles) ->

    getFilename: -> 'index.html'

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['index.jade']
      if not template?
        return callback new Error "unknown index template '#{ options.template }'"

      # console.log(@articles.map((x) -> x?.metadata?.featured))
      # setup the template context
      ctx = {
        @articles,
        inspect: require('util').inspect,
        featured: _.find(@articles, (x) -> x?.metadata?.featured)
      }

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback


  # register a generator, 'paginator' here is the content group generated content will belong to
  # i.e. contents._.paginator
  env.registerGenerator 'index', (contents, callback) ->
    # console.log contents
    # find all articles
    articles = env.helpers.getArticles contents
    # tags = processTags articles
    

    # # populate pages
    # numPages = Math.ceil articles.length / options.perPage
    # pages = []
    # for i in [0...numPages]
    #   pageArticles = articles.slice i * options.perPage, (i + 1) * options.perPage
    #   pages.push new PaginatorPage i + 1, pageArticles

    # # add references to prev/next to each page
    # for page, i in pages
    #   page.prevPage = pages[i - 1]
    #   page.nextPage = pages[i + 1]

    # # create the object that will be merged with the content tree (contents)
    # # do _not_ modify the tree directly inside a generator, consider it read-only
    rv = { pages:{} }

    rv.pages['main.index'] = new IndexPage articles
    
    # for page in pages
    #   rv.pages["#{ page.pageNum }.page"] = page # file extension is arbitrary

    # rv['index.page'] = pages[0] # alias for first page
    # rv['last.page'] = pages[(numPages-1)] # alias for last page

    # # console.time('crate tag pags')
    # for tag in Object.keys(tags)
    #   # arts = getArticlesByTag articles, tag
    #   rv.pages["#{ tag }.tag"] = new TagPage tag, tags[tag
    # console.timeEnd('crate tag pags')
    # console.log rv
    # callback with the generated contents
    callback null, rv

  # tell the plugin manager we are done
  callback()
