From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/21] SUNRPC: Rename rpcb_getport to be consistent
	with new	rpcb_getport_sync name
Date: Sun, 01 Jul 2007 12:13:17 -0400
Message-ID: <20070701161317.2786.70674.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I525y-0004nq-Ro
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:16:18 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5262-0005lr-4e
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:16:22 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Clean up, for consistency.  Rename rpcb_getport as rpcb_getport_async, to
match the naming scheme of rpcb_getport_sync.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    2 +-
 net/sunrpc/rpcb_clnt.c      |   37 +++++++++++++++++++------------------
 net/sunrpc/xprtsock.c       |    4 ++--
 3 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index b28d919..c1b3797 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -122,8 +122,8 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 
 int		rpcb_register(u32, u32, int, unsigned short, int *);
-void		rpcb_getport(struct rpc_task *);
 int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
+void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 23dc65a..1fd3b7e 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -300,13 +300,13 @@ int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
 EXPORT_SYMBOL_GPL(rpcb_getport_sync);
 
 /**
- * rpcb_getport - obtain the port for a given RPC service on a given host
+ * rpcb_getport_async - obtain the port for a given RPC service on a given host
  * @task: task that is waiting for portmapper request
  *
  * This one can be called for an ongoing RPC request, and can be used in
  * an async (rpciod) context.
  */
-void rpcb_getport(struct rpc_task *task)
+void rpcb_getport_async(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
 	int bind_version;
@@ -317,17 +317,17 @@ void rpcb_getport(struct rpc_task *task)
 	struct sockaddr addr;
 	int status;
 
-	dprintk("RPC: %5u rpcb_getport(%s, %u, %u, %d)\n",
-			task->tk_pid, clnt->cl_server,
-			clnt->cl_prog, clnt->cl_vers, xprt->prot);
+	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
+		task->tk_pid, __FUNCTION__,
+		clnt->cl_server, clnt->cl_prog, clnt->cl_vers, xprt->prot);
 
 	/* Autobind on cloned rpc clients is discouraged */
 	BUG_ON(clnt->cl_parent != clnt);
 
 	if (xprt_test_and_set_binding(xprt)) {
 		status = -EACCES;		/* tell caller to check again */
-		dprintk("RPC: %5u rpcb_getport waiting for another binder\n",
-				task->tk_pid);
+		dprintk("RPC: %5u %s: waiting for another binder\n",
+			task->tk_pid, __FUNCTION__);
 		goto bailout_nowake;
 	}
 
@@ -338,27 +338,28 @@ void rpcb_getport(struct rpc_task *task)
 	/* Someone else may have bound if we slept */
 	if (xprt_bound(xprt)) {
 		status = 0;
-		dprintk("RPC: %5u rpcb_getport already bound\n", task->tk_pid);
+		dprintk("RPC: %5u %s: already bound\n",
+			task->tk_pid, __FUNCTION__);
 		goto bailout_nofree;
 	}
 
 	if (rpcb_next_version[xprt->bind_index].rpc_proc == NULL) {
 		xprt->bind_index = 0;
 		status = -EACCES;	/* tell caller to try again later */
-		dprintk("RPC: %5u rpcb_getport no more getport versions "
-				"available\n", task->tk_pid);
+		dprintk("RPC: %5u %s: no more getport versions available\n",
+			task->tk_pid, __FUNCTION__);
 		goto bailout_nofree;
 	}
 	bind_version = rpcb_next_version[xprt->bind_index].rpc_vers;
 
-	dprintk("RPC: %5u rpcb_getport trying rpcbind version %u\n",
-			task->tk_pid, bind_version);
+	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
+		task->tk_pid, __FUNCTION__, bind_version);
 
 	map = kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
 	if (!map) {
 		status = -ENOMEM;
-		dprintk("RPC: %5u rpcb_getport no memory available\n",
-				task->tk_pid);
+		dprintk("RPC: %5u %s: no memory available\n",
+			task->tk_pid, __FUNCTION__);
 		goto bailout_nofree;
 	}
 	map->r_prog = clnt->cl_prog;
@@ -376,8 +377,8 @@ void rpcb_getport(struct rpc_task *task)
 	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot, bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
-		dprintk("RPC: %5u rpcb_getport rpcb_create failed, error %ld\n",
-				task->tk_pid, PTR_ERR(rpcb_clnt));
+		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
+			task->tk_pid, __FUNCTION__, PTR_ERR(rpcb_clnt));
 		goto bailout;
 	}
 
@@ -385,8 +386,8 @@ void rpcb_getport(struct rpc_task *task)
 	rpc_release_client(rpcb_clnt);
 	if (IS_ERR(child)) {
 		status = -EIO;
-		dprintk("RPC: %5u rpcb_getport rpc_run_task failed\n",
-				task->tk_pid);
+		dprintk("RPC: %5u %s: rpc_run_task failed\n",
+			task->tk_pid, __FUNCTION__);
 		goto bailout_nofree;
 	}
 	rpc_put_task(child);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee6ad3b..a8f7c5f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1473,7 +1473,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
-	.rpcbind		= rpcb_getport,
+	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
@@ -1490,7 +1490,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 static struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
-	.rpcbind		= rpcb_getport,
+	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
