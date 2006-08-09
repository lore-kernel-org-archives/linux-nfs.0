From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 21/25] SUNRPC: Eliminate xprt_create_proto and
	rpc_create_client
Date: Wed, 09 Aug 2006 10:59:41 -0400
Message-ID: <20060809145941.3914.55810.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcW-0000ps-5e
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:20 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcU-0003Ii-Af
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:20 -0700
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

The two function call API for creating a new RPC client is now obsolete.
Remove it.

Also, remove an unnecessary check to see whether the caller is capable of
using privileged network services.  The kernel RPC client always uses a
privileged ephemeral port by default; callers are responsible for checking
the authority of users to make use of any RPC service, or for specifying
that a nonprivileged port is acceptable.

Test plan:
Repeated runs of Connectathon locking suite.  Check network trace to ensure
correctness of NLM requests and replies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    7 ----
 include/linux/sunrpc/xprt.h |    1 -
 net/sunrpc/clnt.c           |   42 +----------------------
 net/sunrpc/sunrpc_syms.c    |    3 --
 net/sunrpc/xprt.c           |   79 -------------------------------------------
 net/sunrpc/xprtsock.c       |    2 -
 6 files changed, 1 insertions(+), 133 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 7817ba8..f6d1d64 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -91,13 +91,6 @@ struct rpc_procinfo {
 
 #ifdef __KERNEL__
 
-struct rpc_clnt *rpc_create_client(struct rpc_xprt *xprt, char *servname,
-				struct rpc_program *info,
-				u32 version, rpc_authflavor_t authflavor);
-struct rpc_clnt *rpc_new_client(struct rpc_xprt *xprt, char *servname,
-				struct rpc_program *info,
-				u32 version, rpc_authflavor_t authflavor);
-
 struct rpc_create_args {
 	int			protocol;
 	struct sockaddr		*address;
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index ceaaaa0..68e93ad 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -231,7 +231,6 @@ #ifdef __KERNEL__
 /*
  * Transport operations used by ULPs
  */
-struct rpc_xprt *	xprt_create_proto(int proto, struct sockaddr_in *addr, struct rpc_timeout *to);
 void			xprt_set_timeout(struct rpc_timeout *to, unsigned int retr, unsigned long incr);
 
 /*
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9a1f63c..0a8a2c7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -97,17 +97,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt,
 	}
 }
 
-/*
- * Create an RPC client
- * FIXME: This should also take a flags argument (as in task->tk_flags).
- * It's called (among others) from pmap_create_client, which may in
- * turn be called by an async task. In this case, rpciod should not be
- * made to sleep too long.
- */
-struct rpc_clnt *
-rpc_new_client(struct rpc_xprt *xprt, char *servname,
-		  struct rpc_program *program, u32 vers,
-		  rpc_authflavor_t flavor)
+static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, struct rpc_program *program, u32 vers, rpc_authflavor_t flavor)
 {
 	struct rpc_version	*version;
 	struct rpc_clnt		*clnt = NULL;
@@ -254,36 +244,6 @@ struct rpc_clnt *rpc_create(struct rpc_c
 }
 EXPORT_SYMBOL(rpc_create);
 
-/**
- * Create an RPC client
- * @xprt - pointer to xprt struct
- * @servname - name of server
- * @info - rpc_program
- * @version - rpc_program version
- * @authflavor - rpc_auth flavour to use
- *
- * Creates an RPC client structure, then pings the server in order to
- * determine if it is up, and if it supports this program and version.
- *
- * This function should never be called by asynchronous tasks such as
- * the portmapper.
- */
-struct rpc_clnt *rpc_create_client(struct rpc_xprt *xprt, char *servname,
-		struct rpc_program *info, u32 version, rpc_authflavor_t authflavor)
-{
-	struct rpc_clnt *clnt;
-	int err;
-	
-	clnt = rpc_new_client(xprt, servname, info, version, authflavor);
-	if (IS_ERR(clnt))
-		return clnt;
-	err = rpc_ping(clnt, RPC_TASK_SOFT|RPC_TASK_NOINTR);
-	if (err == 0)
-		return clnt;
-	rpc_shutdown_client(clnt);
-	return ERR_PTR(err);
-}
-
 /*
  * This function clones the RPC client structure. It allows us to share the
  * same transport while varying parameters such as the authentication
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index f38f939..26c0531 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -36,8 +36,6 @@ EXPORT_SYMBOL(rpc_wake_up_status);
 EXPORT_SYMBOL(rpc_release_task);
 
 /* RPC client functions */
-EXPORT_SYMBOL(rpc_create_client);
-EXPORT_SYMBOL(rpc_new_client);
 EXPORT_SYMBOL(rpc_clone_client);
 EXPORT_SYMBOL(rpc_bind_new_program);
 EXPORT_SYMBOL(rpc_destroy_client);
@@ -57,7 +55,6 @@ EXPORT_SYMBOL(rpc_queue_upcall);
 EXPORT_SYMBOL(rpc_mkpipe);
 
 /* Client transport */
-EXPORT_SYMBOL(xprt_create_proto);
 EXPORT_SYMBOL(xprt_set_timeout);
 
 /* Client credential cache */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a8eb2fb..507a96a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -966,85 +966,6 @@ struct rpc_xprt *xprt_create_transport(i
 	return xprt;
 }
 
-static struct rpc_xprt *xprt_setup(int proto, struct sockaddr_in *ap, struct rpc_timeout *to)
-{
-	int result;
-	struct rpc_xprt	*xprt;
-	struct rpc_rqst	*req;
-
-	if ((xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL)) == NULL)
-		return ERR_PTR(-ENOMEM);
-
-	memcpy(&xprt->addr, ap, sizeof(*ap));
-	xprt->addrlen = sizeof(*ap);
-
-	switch (proto) {
-	case IPPROTO_UDP:
-		result = xs_setup_udp(xprt, to);
-		break;
-	case IPPROTO_TCP:
-		result = xs_setup_tcp(xprt, to);
-		break;
-	default:
-		printk(KERN_ERR "RPC: unrecognized transport protocol: %d\n",
-				proto);
-		result = -EIO;
-		break;
-	}
-	if (result) {
-		kfree(xprt);
-		return ERR_PTR(result);
-	}
-
-	spin_lock_init(&xprt->transport_lock);
-	spin_lock_init(&xprt->reserve_lock);
-
-	INIT_LIST_HEAD(&xprt->free);
-	INIT_LIST_HEAD(&xprt->recv);
-	INIT_WORK(&xprt->task_cleanup, xprt_autoclose, xprt);
-	init_timer(&xprt->timer);
-	xprt->timer.function = xprt_init_autodisconnect;
-	xprt->timer.data = (unsigned long) xprt;
-	xprt->last_used = jiffies;
-	xprt->cwnd = RPC_INITCWND;
-
-	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
-	rpc_init_wait_queue(&xprt->pending, "xprt_pending");
-	rpc_init_wait_queue(&xprt->sending, "xprt_sending");
-	rpc_init_wait_queue(&xprt->resend, "xprt_resend");
-	rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
-
-	/* initialize free list */
-	for (req = &xprt->slot[xprt->max_reqs-1]; req >= &xprt->slot[0]; req--)
-		list_add(&req->rq_list, &xprt->free);
-
-	xprt_init_xid(xprt);
-
-	dprintk("RPC:      created transport %p with %u slots\n", xprt,
-			xprt->max_reqs);
-	
-	return xprt;
-}
-
-/**
- * xprt_create_proto - create an RPC client transport
- * @proto: requested transport protocol
- * @sap: remote peer's address
- * @to: timeout parameters for new transport
- *
- */
-struct rpc_xprt *xprt_create_proto(int proto, struct sockaddr_in *sap, struct rpc_timeout *to)
-{
-	struct rpc_xprt	*xprt;
-
-	xprt = xprt_setup(proto, sap, to);
-	if (IS_ERR(xprt))
-		dprintk("RPC:      xprt_create_proto failed\n");
-	else
-		dprintk("RPC:      xprt_create_proto created xprt %p\n", xprt);
-	return xprt;
-}
-
 /**
  * xprt_destroy - destroy an RPC transport, killing off all requests.
  * @xprt: transport to destroy
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ababfe9..795e959 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1371,7 +1371,6 @@ int xs_setup_udp(struct rpc_xprt *xprt, 
 
 	xprt->prot = IPPROTO_UDP;
 	xprt->tsh_size = 0;
-	xprt->resvport = capable(CAP_NET_BIND_SERVICE) ? 1 : 0;
 	/* XXX: header size can vary due to auth type, IPv6, etc. */
 	xprt->max_payload = (1U << 16) - (MAX_HEADER << 3);
 
@@ -1418,7 +1417,6 @@ int xs_setup_tcp(struct rpc_xprt *xprt, 
 
 	xprt->prot = IPPROTO_TCP;
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
-	xprt->resvport = capable(CAP_NET_BIND_SERVICE) ? 1 : 0;
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
 	INIT_WORK(&xprt->connect_worker, xs_tcp_connect_worker, xprt);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
