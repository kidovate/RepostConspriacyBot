@FileComment = (originalPost, previousPosts) ->
  return if @CommentQueue.findOne(postId: originalPost.id)?

  tableEntries = ""
  entryCount = 0
  for post in previousPosts
    post = post.data
    #console.log EJSON.stringify post
    if post.id is originalPost.id
      continue
    tableEntries += "[Link](http://reddit.com"+post.permalink+")|"+post.score+"|"+post.title.replace("|", "-")+"|"+post.num_comments+"\n"
    entryCount++
  commentText = "This link has been posted "+entryCount+" times, here is a table if you wish to read any exisiting discussion:\n\nLink|Score|Title|Comments\n:---|:--:|:--:|---:\n"+tableEntries+"\n\n[**Why?**](http://repostconspiracybot.herokuapp.com/)"

  if entryCount isnt 0
    @CommentQueue.insert
      postId: originalPost.id
      date: (new Date().getTime())
      posted: false
      repostCount: entryCount
      text: commentText