From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 16/25] SUNRPC: use sockaddr + size when creating
	remote transport endpoints
Date: Wed, 09 Aug 2006 10:59:29 -0400
Message-ID: <20060809145928.3914.96792.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcW-0000pw-BQ
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:20 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcT-0003IO-If
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

Prepare for more generic transport endpoint handling needed by transports
that might use different forms of addressing, such as IPv6.

Introduce a single function call to replace the two-call
xprt_create_proto/rpc_create_client API.  Define a new rpc_create_args
structure that allows callers to pass in remote endpoint addresses of
varying length.

Test-plan:
Compile kernel with CONFIG_NFS enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |   22 +++++++++++++
 include/linux/sunrpc/xprt.h |    1 +
 net/sunrpc/clnt.c           |   61 +++++++++++++++++++++++++++++++++++
 net/sunrpc/xprt.c           |   75 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 159 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a26d695..7817ba8 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -97,6 +97,28 @@ struct rpc_clnt *rpc_create_client(struc
 struct rpc_clnt *rpc_new_client(struct rpc_xprt *xprt, char *servname,
 				struct rpc_program *info,
 				u32 version, rpc_authflavor_t authflavor);
+
+struct rpc_create_args {
+	int			protocol;
+	struct sockaddr		*address;
+	size_t			addrsize;
+	struct rpc_timeout	*timeout;
+	char			*servername;
+	struct rpc_program	*program;
+	u32			version;
+	rpc_authflavor_t	authflavor;
+	unsigned long		flags;
+};
+
+/* Values for "flags" field */
+#define RPC_CLNT_CREATE_HARDRTRY	(1UL << 0)
+#define RPC_CLNT_CREATE_INTR		(1UL << 1)
+#define RPC_CLNT_CREATE_AUTOBIND	(1UL << 2)
+#define RPC_CLNT_CREATE_ONESHOT		(1UL << 3)
+#define RPC_CLNT_CREATE_NONPRIVPORT	(1UL << 4)
+#define RPC_CLNT_CREATE_NOPING		(1UL << 5)
+
+struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 				struct rpc_program *, int);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 2cbd689..ceaaaa0 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -237,6 +237,7 @@ void			xprt_set_timeout(struct rpc_timeo
 /*
  * Generic internal transport functions
  */
+struct rpc_xprt *	xprt_create_transport(int proto, struct sockaddr *addr, size_t size, struct rpc_timeout *toparms);
 void			xprt_connect(struct rpc_task *task);
 void			xprt_reserve(struct rpc_task *task);
 int			xprt_reserve_xprt(struct rpc_task *task);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 742cb1e..9a1f63c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -193,6 +193,67 @@ out_no_xprt:
 	return ERR_PTR(err);
 }
 
+/*
+ * rpc_create - create an RPC client and transport with one call
+ * @args: rpc_clnt create argument structure
+ *
+ * Creates and initializes an RPC transport and an RPC client.
+ *
+ * It can ping the server in order to determine if it is up, and to see if
+ * it supports this program and version.  RPC_CLNT_CREATE_NOPING disables
+ * this behavior so asynchronous tasks can also use rpc_create.
+ */
+struct rpc_clnt *rpc_create(struct rpc_create_args *args)
+{
+	struct rpc_xprt *xprt;
+	struct rpc_clnt *clnt;
+
+	xprt = xprt_create_transport(args->protocol, args->address,
+					args->addrsize, args->timeout);
+	if (IS_ERR(xprt))
+		return (struct rpc_clnt *)xprt;
+
+	/*
+	 * By default, kernel RPC client connects from a reserved port.
+	 * CAP_NET_BIND_SERVICE will not be set for unprivileged requesters,
+	 * but it is always enabled for rpciod, which handles the connect
+	 * operation.
+	 */
+	xprt->resvport = 1;
+	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
+		xprt->resvport = 0;
+
+	dprintk("RPC:       creating %s client for %s (xprt %p)\n",
+		args->program->name, args->servername, xprt);
+
+	clnt = rpc_new_client(xprt, args->servername, args->program,
+				args->version, args->authflavor);
+	if (IS_ERR(clnt))
+		return clnt;
+
+	if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
+		int err = rpc_ping(clnt, RPC_TASK_SOFT|RPC_TASK_NOINTR);
+		if (err != 0) {
+			rpc_shutdown_client(clnt);
+			return ERR_PTR(err);
+		}
+	}
+
+	clnt->cl_softrtry = 1;
+	if (args->flags & RPC_CLNT_CREATE_HARDRTRY)
+		clnt->cl_softrtry = 0;
+
+	if (args->flags & RPC_CLNT_CREATE_INTR)
+		clnt->cl_intr = 1;
+	if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
+		clnt->cl_autobind = 1;
+	if (args->flags & RPC_CLNT_CREATE_ONESHOT)
+		clnt->cl_oneshot = 1;
+
+	return clnt;
+}
+EXPORT_SYMBOL(rpc_create);
+
 /**
  * Create an RPC client
  * @xprt - pointer to xprt struct
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index dcc0bd7..a8eb2fb 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -891,6 +891,81 @@ void xprt_set_timeout(struct rpc_timeout
 	to->to_exponential = 0;
 }
 
+/**
+ * xprt_create_transport - create an RPC transport
+ * @proto: requested transport protocol
+ * @ap: remote peer address
+ * @size: length of address
+ * @to: timeout parameters
+ *
+ */
+struct rpc_xprt *xprt_create_transport(int proto, struct sockaddr *ap, size_t size, struct rpc_timeout *to)
+{
+	int result;
+	struct rpc_xprt	*xprt;
+	struct rpc_rqst	*req;
+
+	if ((xprt = kzalloc(sizeof(struct rpc_xprt), GFP_KERNEL)) == NULL) {
+		dprintk("RPC:      xprt_create_transport: no memory\n");
+		return ERR_PTR(-ENOMEM);
+	}
+	if (size <= sizeof(xprt->addr)) {
+		memcpy(&xprt->addr, ap, size);
+		xprt->addrlen = size;
+	} else {
+		kfree(xprt);
+		dprintk("RPC:      xprt_create_transport: address too large\n");
+		return ERR_PTR(-EBADF);
+	}
+
+	switch (proto) {
+	case IPPROTO_UDP:
+		result = xs_setup_udp(xprt, to);
+		break;
+	case IPPROTO_TCP:
+		result = xs_setup_tcp(xprt, to);
+		break;
+	default:
+		printk(KERN_ERR "RPC: unrecognized transport protocol: %d\n",
+				proto);
+		return ERR_PTR(-EIO);
+	}
+	if (result) {
+		kfree(xprt);
+		dprintk("RPC:      xprt_create_transport: failed, %d\n", result);
+		return ERR_PTR(result);
+	}
+
+	spin_lock_init(&xprt->transport_lock);
+	spin_lock_init(&xprt->reserve_lock);
+
+	INIT_LIST_HEAD(&xprt->free);
+	INIT_LIST_HEAD(&xprt->recv);
+	INIT_WORK(&xprt->task_cleanup, xprt_autoclose, xprt);
+	init_timer(&xprt->timer);
+	xprt->timer.function = xprt_init_autodisconnect;
+	xprt->timer.data = (unsigned long) xprt;
+	xprt->last_used = jiffies;
+	xprt->cwnd = RPC_INITCWND;
+
+	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
+	rpc_init_wait_queue(&xprt->pending, "xprt_pending");
+	rpc_init_wait_queue(&xprt->sending, "xprt_sending");
+	rpc_init_wait_queue(&xprt->resend, "xprt_resend");
+	rpc_init_priority_wait_queue(&xprt->backlog, "xprt_backlog");
+
+	/* initialize free list */
+	for (req = &xprt->slot[xprt->max_reqs-1]; req >= &xprt->slot[0]; req--)
+		list_add(&req->rq_list, &xprt->free);
+
+	xprt_init_xid(xprt);
+
+	dprintk("RPC:      created transport %p with %u slots\n", xprt,
+			xprt->max_reqs);
+
+	return xprt;
+}
+
 static struct rpc_xprt *xprt_setup(int proto, struct sockaddr_in *ap, struct rpc_timeout *to)
 {
 	int result;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
