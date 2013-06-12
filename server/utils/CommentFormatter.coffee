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
  commentText = "This link has already been posted before, here are the other posts:\n\nLink|Score|Title|Comments\n:---|:--:|:--:|---:\n"+tableEntries+"\n\n[**Why?**](http://pastebin.com/raw.php?i=7cWEzCaa)"

  if entryCount isnt 0
    @CommentQueue.insert
      postId: originalPost.id
      date: (new Date().getTime())
      posted: false
      repostCount: entryCount
      text: commentText