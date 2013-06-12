PostingQueuedComments = false
CommentPosterCron = new Cron(1000)
#Post a single comment, one per 2 seconds
@PostQueuedCommentsLoop = ()->
  if PostingQueuedComments
    return
  PostingQueuedComments = true
  if @LoginCookie?
    loginCookie = @LoginCookie
    #Begin posting
    commentToPost = @CommentQueue.findOne({posted:false}, {sort: {repostCount: -1}})
    if commentToPost?
      #console.log "Posting comment: "+commentToPost.text
      try
        result = Meteor.http.post "http://www.reddit.com/api/comment", {
          headers:
            "cookie": loginCookie
          params:
            api_type: "json"
            text: commentToPost.text
            thing_id: "t3_"+commentToPost.postId
            uh: LoginModHash
          followRedirects: true
        }
      catch error
        console.log error.stack
      if result.statusCode isnt 200 or result.data.json.errors.length isnt 0
        #check for ratelimit
        if result.data.json.ratelimit?
          rateLimitSeconds = result.data.json.ratelimit
          console.log "Comment post ratelimit reached, waiting "+rateLimitSeconds+" to post."
          PostingQueuedComments = false
          CommentPosterCron.addScheduleJob(Math.round((new Date()).getTime() / 1000)+rateLimitSeconds, ()->
            PostQueuedCommentsLoop()
          )
          return
        console.log "Error "+result.statusCode+" when posting comment."
        console.log EJSON.stringify result.data
      @CommentQueue.update({_id: commentToPost._id}, {$set: {posted: true}})
  PostingQueuedComments = false
  CommentPosterCron.addScheduleJob(Math.round((new Date()).getTime() / 1000) + 2, ()->
    PostQueuedCommentsLoop()
  )


Meteor.startup PostQueuedCommentsLoop