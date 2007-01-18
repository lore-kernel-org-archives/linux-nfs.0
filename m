From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/14] SUNRPC: Eliminate side effects from rpc_malloc
Date: Thu, 18 Jan 2007 18:29:53 -0500
Message-ID: <20070118232953.23310.81299.stgit@localhost.localdomain>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7gi3-0002nt-R3
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:20 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7gi1-0004Nh-PG
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:18 -0800
To: trond.myklybust@fys.uio.no
In-Reply-To: <20070118232356.23310.6705.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Currently rpc_malloc sets req->rq_buffer internally.  Make this a cleaner
interface:  return a pointer to the new buffer (or NULL) and make the
caller set req->rq_buffer and req->rq_bufsize.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c  |    5 ++++-
 net/sunrpc/sched.c |   14 +++-----------
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f837335..244cce4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -765,8 +765,11 @@ call_allocate(struct rpc_task *task)
 	 * auth->au_wslack */
 	bufsiz = task->tk_msg.rpc_proc->p_bufsiz + RPC_SLACK_SPACE;
 
-	if (xprt->ops->buf_alloc(task, bufsiz << 1) != NULL)
+	req->rq_buffer = xprt->ops->buf_alloc(task, bufsiz << 1);
+	if (req->rq_buffer != NULL) {
+		req->rq_bufsize = bufsiz;
 		return;
+	}
 
 	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
 
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index cb0c5f4..08104dd 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -749,7 +749,6 @@ static void rpc_async_schedule(struct wo
  */
 void * rpc_malloc(struct rpc_task *task, size_t size)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
 	gfp_t	gfp;
 
 	if (task->tk_flags & RPC_TASK_SWAPPER)
@@ -757,16 +756,9 @@ void * rpc_malloc(struct rpc_task *task,
 	else
 		gfp = GFP_NOFS;
 
-	if (size > RPC_BUFFER_MAXSIZE) {
-		req->rq_buffer = kmalloc(size, gfp);
-		if (req->rq_buffer)
-			req->rq_bufsize = size;
-	} else {
-		req->rq_buffer = mempool_alloc(rpc_buffer_mempool, gfp);
-		if (req->rq_buffer)
-			req->rq_bufsize = RPC_BUFFER_MAXSIZE;
-	}
-	return req->rq_buffer;
+	if (size <= RPC_BUFFER_MAXSIZE)
+		return mempool_alloc(rpc_buffer_mempool, gfp);
+	return kmalloc(size, gfp);
 }
 
 /**

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
