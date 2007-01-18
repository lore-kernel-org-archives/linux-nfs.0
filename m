From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/14] SUNRPC: Make rpc_free API more generic
Date: Thu, 18 Jan 2007 18:30:02 -0500
Message-ID: <20070118233002.23310.88831.stgit@localhost.localdomain>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7giZ-0002p6-L9
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:53 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7gia-0003Mv-6V
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:53 -0800
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

Don't diddle with rq_buffer and rq_bufsize inside of rpc_free.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/sched.h |    2 +-
 include/linux/sunrpc/xprt.h  |    2 +-
 net/sunrpc/sched.c           |   15 +++++++--------
 net/sunrpc/xprt.c            |    2 +-
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 97c7616..88e6e39 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -265,7 +265,7 @@ struct rpc_task *rpc_wake_up_next(struct
 void		rpc_wake_up_status(struct rpc_wait_queue *, int);
 void		rpc_delay(struct rpc_task *, unsigned long);
 void *		rpc_malloc(struct rpc_task *, size_t);
-void		rpc_free(struct rpc_task *);
+void		rpc_free(struct rpc_task *, void *, size_t);
 int		rpciod_up(void);
 void		rpciod_down(void);
 int		__rpc_wait_for_completion_task(struct rpc_task *task, int (*)(void *));
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index f780e72..51c3660 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -112,7 +112,7 @@ struct rpc_xprt_ops {
 	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
 	void		(*connect)(struct rpc_task *task);
 	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
-	void		(*buf_free)(struct rpc_task *task);
+	void		(*buf_free)(struct rpc_task *task, void *buffer, size_t size);
 	int		(*send_request)(struct rpc_task *task);
 	void		(*set_retrans_timeout)(struct rpc_task *task);
 	void		(*timer)(struct rpc_task *task);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 08104dd..c689196 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -763,20 +763,19 @@ void * rpc_malloc(struct rpc_task *task,
 
 /**
  * rpc_free - free buffer allocated via rpc_malloc
- * @task: RPC task with a buffer to be freed
+ * @task: RPC task used when this buffer was allocated
+ * @buffer: buffer to free
  *
  */
-void rpc_free(struct rpc_task *task)
+void rpc_free(struct rpc_task *task, void *buffer, size_t size)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
-	if (req->rq_buffer) {
-		if (req->rq_bufsize == RPC_BUFFER_MAXSIZE)
-			mempool_free(req->rq_buffer, rpc_buffer_mempool);
+	if (req) {
+		if (size <= RPC_BUFFER_MAXSIZE)
+			mempool_free(buffer, rpc_buffer_mempool);
 		else
-			kfree(req->rq_buffer);
-		req->rq_buffer = NULL;
-		req->rq_bufsize = 0;
+			kfree(buffer);
 	}
 }
 
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index cf59f7d..9f787ac 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -855,7 +855,7 @@ void xprt_release(struct rpc_task *task)
 		mod_timer(&xprt->timer,
 				xprt->last_used + xprt->idle_timeout);
 	spin_unlock_bh(&xprt->transport_lock);
-	xprt->ops->buf_free(task);
+	xprt->ops->buf_free(task, req->rq_buffer, req->rq_bufsize);
 	task->tk_rqstp = NULL;
 	if (req->rq_release_snd_buf)
 		req->rq_release_snd_buf(req);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
