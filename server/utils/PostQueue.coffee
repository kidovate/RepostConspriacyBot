@PostQueue = []
@FetchingPosts = false
@NewestPostID = null
@BuildPostQueue = ()->
  if @FetchingPosts or @PostQueue.length is 50
    return
  @FetchingPosts = true
  #Retreive the last done post
  latestProcessed = ProcessedPosts.findOne({}, {sort: {date: -1}})
  request = Reddit.list().new().from('week').limit(50) #request so far, only process the ones of this week

  if !latestProcessed?
    console.log "No posts have been processed yet! This will grab 50 of the latest."
  else
    if @NewestPostID is latestProcessed.id
      @FetchingPosts = false
      return
    @NewestPostID = latestProcessed.id
    console.log "Starting at post ID: "+@NewestPostID
    request = request.after(@NewestPostID)

  @PostQueue = []

  @RequestCount++
  @RequestHistory.push (new Date().getTime())
  request.exe (err, data, res)->
    @PostQueue = data.data.children
    console.log ""+@PostQueue.length+" new posts queued!"
    @FetchingPosts = false