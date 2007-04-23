From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] SUNRPC: Rename rpcb_getport* routines
Date: Mon, 23 Apr 2007 18:04:19 -0400
Message-ID: <20070423220419.24305.95796.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6e3-0003Pn-M6
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:27 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6e5-0008Q7-SJ
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:30 -0700
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

In preparation for handling NFS mount option parsing in the kernel,
rename rpcb_getport_external as rpcb_get_port_sync, and make it available
always (instead of only when CONFIG_ROOT_NFS is enabled).  Also rename
rpcb_getport as rpcb_getport_async, for consistency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c            |    2 +-
 include/linux/sunrpc/clnt.h |    9 ++-----
 net/sunrpc/rpcb_clnt.c      |   56 ++++++++++++++++++++++---------------------
 net/sunrpc/xprtsock.c       |    4 ++-
 4 files changed, 35 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 49d1008..f0db470 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -428,7 +428,7 @@ static int __init root_nfs_getport(int program, int version, int proto)
 	printk(KERN_NOTICE "Looking up port of RPC %d/%d on %u.%u.%u.%u\n",
 		program, version, NIPQUAD(servaddr));
 	set_sockaddr(&sin, servaddr, 0);
-	return rpcb_getport_external(&sin, program, version, proto);
+	return rpcb_getport_sync(&sin, program, version, proto);
 }
 
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6661142..97348c3 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -122,8 +122,10 @@ struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 int		rpc_shutdown_client(struct rpc_clnt *);
 int		rpc_destroy_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
+
 int		rpcb_register(u32, u32, int, unsigned short, int *);
-void		rpcb_getport(struct rpc_task *);
+void		rpcb_getport_async(struct rpc_task *);
+int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
 
 void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
 
@@ -142,10 +144,5 @@ int		rpc_ping(struct rpc_clnt *clnt, int flags);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 char *		rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 
-/*
- * Helper function for NFSroot support
- */
-int		rpcb_getport_external(struct sockaddr_in *, __u32, __u32, int);
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 86744c7..0908caf 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -12,6 +12,8 @@
  *  Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
  */
 
+#include <linux/module.h>
+
 #include <linux/types.h>
 #include <linux/socket.h>
 #include <linux/in.h>
@@ -258,9 +260,8 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 	return error;
 }
 
-#ifdef CONFIG_ROOT_NFS
 /**
- * rpcb_getport_external - obtain the port for an RPC service on a given host
+ * rpcb_getport_sync - obtain the port for an RPC service on a given host
  * @sin: address of remote peer
  * @prog: RPC program number to bind
  * @vers: RPC version number to bind
@@ -268,11 +269,11 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
  *
  * Called from outside the RPC client in a synchronous task context.
  *
- * For now, this supports only version 2 queries, but is used only by
- * mount_clnt for NFS_ROOT.
+ * XXX: Needs a reasonable timeout, such as xprt->bind_timeout
+ * XXX: Needs to support IPv6, rpcbind versions 3 and 4
  */
-int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
-				__u32 vers, int prot)
+int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
+		      __u32 vers, int prot)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
@@ -289,8 +290,8 @@ int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
 	char hostname[40];
 	int status;
 
-	dprintk("RPC:       rpcb_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
-			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
+	dprintk("RPC:       %s(%u.%u.%u.%u, %u, %u, %d)\n",
+		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
 	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
@@ -306,16 +307,16 @@ int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
 	}
 	return status;
 }
-#endif
+EXPORT_SYMBOL_GPL(rpcb_getport_sync);
 
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
@@ -326,17 +327,17 @@ void rpcb_getport(struct rpc_task *task)
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
 
@@ -347,27 +348,28 @@ void rpcb_getport(struct rpc_task *task)
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
@@ -385,16 +387,16 @@ void rpcb_getport(struct rpc_task *task)
 	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot, bind_version, 0);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
-		dprintk("RPC: %5u rpcb_getport rpcb_create failed, error %ld\n",
-				task->tk_pid, PTR_ERR(rpcb_clnt));
+		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
+			task->tk_pid, __FUNCTION__, PTR_ERR(rpcb_clnt));
 		goto bailout;
 	}
 
 	child = rpc_run_task(rpcb_clnt, RPC_TASK_ASYNC, &rpcb_getport_ops, map);
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
index e060f58..69f0e86 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1717,7 +1717,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
-	.rpcbind		= rpcb_getport,
+	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
@@ -1734,7 +1734,7 @@ static struct rpc_xprt_ops xs_udp_ops = {
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
