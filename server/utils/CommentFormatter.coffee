@FileComment = (originalPost, previousPosts) ->
  return if @CommentQueue.findOne(postId: originalPost.id)?

  tableEntries = ""
  entryCount = 0
  for post in previousPosts
    post = post.data
    #console.log EJSON.stringify post
    if post.id is originalPost.id
      continue
    tableEntries += post.subreddit+"|"+post.score+"|["+post.title.replace("|", "").replace("]", "")+"](http://reddit.com"+post.permalink+")|"+post.num_comments+"\n"
    entryCount++
  commentText = "This link has been posted "+entryCount+" other times, here is a table if you wish to read any exisiting discussion:\n\nSubreddit|Score|Title|Comments\n:---|:--:|:--:|---:\n"+tableEntries+"\n\n[**Info + Statistics**](http://repostconspiracybot.herokuapp.com/)"

  if entryCount > 3 #filter it down a bit
    @CommentQueue.insert
      postId: originalPost.id
      date: (new Date().getTime())
      posted: false
      repostCount: entryCount
      text: commentText