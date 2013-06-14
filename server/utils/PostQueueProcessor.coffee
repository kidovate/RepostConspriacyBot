@ProcessingPosts = false
@ProcessPostQueue = ()->
  if @ProcessingPosts
    return
  #console.log "Processing posts"
  @ProcessingPosts = true
  try
    #Run through the queue of posts and check if it has already been posted before, queue a snotty comment
    deferredPosts = []
    ignoredCount = 0
    for item, i in @PostQueue
      postData = item.data
      #From here we can get title --> postData.title
      #console.log "Processing post: "+postData.title
      #ignore if it is already processed
      if @ProcessedPosts.findOne(id: postData.id)?
        #console.log "Already processed, skipped"
        continue

      #Ignore if domain is in the ignore list
      if postData.domain in @IgnoredDomains or postData.domain.substring(0,4) is "self"
        #console.log "Ignoring "+postData.title.substring(0,50)+" - ignored domain "+postData.domain
        ignoredCount++
        @ProcessedPosts.insert
          id: postData.id
          title: postData.title
          score: postData.score
          numrepost: null
          date: postData.created_utc
        continue

      infoUrl = "http://www.reddit.com/api/info.json?url="+encodeURIComponent(postData.url)
      #console.log infoUrl
      #Check the link
      #console.log "Requested url: "+infoUrl
      result = Meteor.http.get infoUrl
      if result.statusCode isnt 200
        console.log "Error "+result.statusCode+" while attempting to check post "+postData.id
        continue

      #posts
      rposts = result.data.data.children
      #quickly file a "checked" record
      @ProcessedPosts.insert
        id: postData.id
        title: postData.title.replace("|", "-")
        score: postData.score
        numrepost: rposts.length-1
        date: postData.created_utc

      if rposts.length > 1
        #uh-oh, repost alert
        console.log "Filing comment for post: "+postData.id+" repost count: "+rposts.length
        @FileComment postData, rposts

      @RequestCount++
      @RequestHistory.push (new Date().getTime())

      if @RequestCount >= @RequestLimit
        deferredPosts = @PostQueue.slice i
        #if deferredPosts.length isnt 0
          #console.log "Deferring "+deferredPosts.length+" posts, request limit reached..."
        break
    @PostQueue = deferredPosts
    #if ignoredCount > 0
    #  console.log "Ignoring "+ignoredCount+" posts for ignored post domains."
  catch error
    console.log "Error while processing posts: "+error

  @ProcessingPosts = false