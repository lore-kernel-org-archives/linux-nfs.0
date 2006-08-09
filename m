From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 06/25] SUNRPC: Introduce transport switch callout for
	pluggable rpcbind
Date: Wed, 09 Aug 2006 10:59:04 -0400
Message-ID: <20060809145904.3914.63196.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApWb-0008LQ-G8
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:13 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApWY-00010F-Qf
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:11 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
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

Introduce a clean transport switch API for plugging in different types of
rpcbind mechanisms.  For instance, rpcbind can cleanly replace the
existing portmapper client, or a transport can choose to implement RPC
binding any way it likes.

Test plan:
Destructive testing (unplugging the network temporarily).  Connectathon
with UDP and TCP.  NFSv2/3 and NFSv4 mounting should be carefully checked.
Probably need to rig a server where certain services aren't running, or
that returns an error for some typical operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    2 +-
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/clnt.c           |    3 +--
 net/sunrpc/pmap_clnt.c      |    4 ++--
 net/sunrpc/xprtsock.c       |    2 ++
 5 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 00e9dba..2e68ac0 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -106,7 +106,7 @@ struct rpc_clnt *rpc_clone_client(struct
 int		rpc_shutdown_client(struct rpc_clnt *);
 int		rpc_destroy_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
-void		rpc_getport(struct rpc_task *, struct rpc_clnt *);
+void		rpc_getport(struct rpc_task *);
 int		rpc_register(u32, u32, int, unsigned short, int *);
 
 void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 445e554..2c4d6c8 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -105,6 +105,7 @@ struct rpc_xprt_ops {
 	void		(*set_buffer_size)(struct rpc_xprt *xprt, size_t sndsize, size_t rcvsize);
 	int		(*reserve_xprt)(struct rpc_task *task);
 	void		(*release_xprt)(struct rpc_xprt *xprt, struct rpc_task *task);
+	void		(*rpcbind)(struct rpc_task *task);
 	void		(*set_port)(struct rpc_xprt *xprt, unsigned short port);
 	void		(*connect)(struct rpc_task *task);
 	void *		(*buf_alloc)(struct rpc_task *task, size_t size);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 87008ff..bff350e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -777,7 +777,6 @@ call_encode(struct rpc_task *task)
 static void
 call_bind(struct rpc_task *task)
 {
-	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_xprt *xprt = task->tk_xprt;
 
 	dprintk("RPC: %4d call_bind (status %d)\n",
@@ -787,7 +786,7 @@ call_bind(struct rpc_task *task)
 	if (!xprt_bound(xprt)) {
 		task->tk_action = call_bind_status;
 		task->tk_timeout = xprt->bind_timeout;
-		rpc_getport(task, clnt);
+		xprt->ops->rpcbind(task);
 	}
 }
 
diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index 1f80ad1..66f18d0 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -81,13 +81,13 @@ static inline void pmap_wake_portmap_wai
 /**
  * rpc_getport - obtain the port for a given RPC service on a given host
  * @task: task that is waiting for portmapper request
- * @clnt: controlling rpc_clnt
  *
  * This one can be called for an ongoing RPC request, and can be used in
  * an async (rpciod) context.
  */
-void rpc_getport(struct rpc_task *task, struct rpc_clnt *clnt)
+void rpc_getport(struct rpc_task *task)
 {
+	struct rpc_clnt *clnt = task->tk_client;
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct sockaddr_in *sap = &xprt->addr;
 	struct portmap_args *map;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 43b59c2..159d591 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1264,6 +1264,7 @@ static struct rpc_xprt_ops xs_udp_ops = 
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong,
+	.rpcbind		= rpc_getport,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
@@ -1280,6 +1281,7 @@ static struct rpc_xprt_ops xs_udp_ops = 
 static struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
 	.release_xprt		= xs_tcp_release_xprt,
+	.rpcbind		= rpc_getport,
 	.set_port		= xs_set_port,
 	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
