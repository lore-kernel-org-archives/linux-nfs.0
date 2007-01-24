From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/15] SUNRPC: introduce rpcbind: replacement for
	in-kernel portmapper
Date: Wed, 24 Jan 2007 14:20:01 -0500
Message-ID: <20070124192000.31133.87571.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ngR-00019S-Qq
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:23 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9ngS-0004PI-Rl
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:25 -0800
In-Reply-To: <20070124191704.31133.12713.stgit@localhost.localdomain>
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

Introduce a replacement for the in-kernel portmapper client that supports
all 3 versions of the rpcbind protocol.  This code is not used yet.

Original code by Groupe Bull updated for the latest kernel, with multiple
bug fixes.

Note that rpcb_clnt.c does not yet support registering via versions 3 and
4 of the rpcbind protocol.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h  |    3 
 include/linux/sunrpc/debug.h |    1 
 include/linux/sunrpc/xprt.h  |    1 
 net/sunrpc/Makefile          |    2 
 net/sunrpc/rpcb_clnt.c       |  531 ++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprt.c            |    1 
 6 files changed, 538 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c7a78ee..702baef 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -123,6 +123,8 @@ int		rpc_destroy_client(struct rpc_clnt 
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_getport(struct rpc_task *);
 int		rpc_register(u32, u32, int, unsigned short, int *);
+int		rpcb_register(u32, u32, int, unsigned short, int *);
+void		rpcb_getport(struct rpc_task *);
 
 void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
 
@@ -145,6 +147,7 @@ char *		rpc_peeraddr2str(struct rpc_clnt
  * Helper function for NFSroot support
  */
 int		rpc_getport_external(struct sockaddr_in *, __u32, __u32, int);
+int		rpcb_getport_external(struct sockaddr_in *, __u32, __u32, int);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 60fce3c..7b11c74 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -18,6 +18,7 @@ #define RPCDBG_DEBUG		0x0004
 #define RPCDBG_NFS		0x0008
 #define RPCDBG_AUTH		0x0010
 #define RPCDBG_PMAP		0x0020
+#define RPCDBG_BIND		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
 #define RPCDBG_SVCSOCK		0x0100
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 51c3660..6c035cb 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -150,6 +150,7 @@ struct rpc_xprt {
 	unsigned long		state;		/* transport state */
 	unsigned char		shutdown   : 1,	/* being shut down */
 				resvport   : 1; /* use a reserved port */
+	unsigned int		bind_index;	/* bind function index */
 
 	/*
 	 * Connection of transports
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index cdcab9c..3417a1e 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
 sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    auth.o auth_null.o auth_unix.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
-	    pmap_clnt.o timer.o xdr.o \
+	    pmap_clnt.o rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
new file mode 100644
index 0000000..28e0a76
--- /dev/null
+++ b/net/sunrpc/rpcb_clnt.c
@@ -0,0 +1,531 @@
+/*
+ * In-kernel rpcbind client supporting versions 2, 3, and 4 of the rpcbind
+ * protocol (RFC 1833).
+ *
+ * Original: Gilles Quillard, Bull Open Source, 2005 <gilles.quillard@bull.net>
+ * Updated: Chuck Lever, Oracle Corporation, 2007 <chuck.lever@oracle.com>
+ *
+ * Based on net/sunrpc/pmap_clnt.c,
+ *  Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
+ */
+
+#include <linux/types.h>
+#include <linux/socket.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/sched.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY	RPCDBG_BIND
+#endif
+
+#define RPC_BIND_PROGRAM	(100000U)
+#define RPC_BIND_PORT		(111U)
+
+#define RPCB_SET		(1)
+#define RPCB_UNSET		(2)
+#define RPCB_GETPORT		(3)
+#define RPCB_GETADDR		(3)
+#define RPCB_GETVERSADDR	(9)
+
+/* US-ASCII netid strings -- must work even on s/390 */
+#define RPCB_NETID_UDP	"\165\144\160"		/* "udp" */
+#define RPCB_NETID_TCP	"\164\143\160"		/* "tcp" */
+
+static void			rpcb_getport_done(struct rpc_task *, void *);
+extern struct rpc_program	rpcb_program;
+
+struct rpcbind_args {
+	struct rpc_xprt *	r_xprt;
+
+	u32			r_prog;
+	u32			r_vers;
+	u32			r_prot;
+	unsigned short		r_port;
+	char *			r_netid;
+	char			r_addr[128];
+	char *			r_owner;
+};
+
+static struct rpc_procinfo rpcb_procedures2[];
+static struct rpc_procinfo rpcb_procedures3[];
+
+static struct rpcb_info {
+	int			rpc_vers;
+	struct rpc_procinfo *	rpc_proc;
+} rpcb_next_version[];
+
+static void rpcb_getport_prepare(struct rpc_task *task, void *calldata)
+{
+	struct rpcbind_args *map = calldata;
+	struct rpc_xprt *xprt = map->r_xprt;
+	struct rpc_message msg = {
+		.rpc_proc	= rpcb_next_version[xprt->bind_index].rpc_proc,
+		.rpc_argp	= map,
+		.rpc_resp	= &map->r_port,
+	};
+
+	rpc_call_setup(task, &msg, 0);
+}
+
+static void rpcb_map_release(void *data)
+{
+	kfree(data);
+}
+
+static const struct rpc_call_ops rpcb_getport_ops = {
+	.rpc_call_prepare	= rpcb_getport_prepare,
+	.rpc_call_done		= rpcb_getport_done,
+	.rpc_release		= rpcb_map_release,
+};
+
+static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
+{
+	xprt_clear_binding(xprt);
+	rpc_wake_up_status(&xprt->binding, status);
+}
+
+static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
+					int proto, int version, int privileged)
+{
+	struct rpc_create_args args = {
+		.protocol	= proto,
+		.address	= srvaddr,
+		.addrsize	= sizeof(struct sockaddr_in),
+		.servername	= hostname,
+		.program	= &rpcb_program,
+		.version	= version,
+		.authflavor	= RPC_AUTH_NULL,
+		.flags		= (RPC_CLNT_CREATE_ONESHOT |
+				   RPC_CLNT_CREATE_NOPING),
+	};
+
+	((struct sockaddr_in *)srvaddr)->sin_port = htons(RPC_BIND_PORT);
+	if (!privileged)
+		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+	return rpc_create(&args);
+}
+
+/**
+ * rpcb_register - set or unset a port registration with the local portmapper
+ * @prog: RPC program number to bind
+ * @vers: RPC version number to bind
+ * @prot: transport protocol to use to make this request
+ * @port: port value to register
+ * @okay: result code
+ *
+ * port == 0 means unregister, port != 0 means register.
+ *
+ * This routine supports only rpcbind version 2.
+ */
+int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
+{
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	};
+	struct rpcbind_args map = {
+		.r_prog		= prog,
+		.r_vers		= vers,
+		.r_prot		= prot,
+		.r_port		= port,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &rpcb_procedures2[port ? RPCB_SET : RPCB_UNSET],
+		.rpc_argp	= &map,
+		.rpc_resp	= okay,
+	};
+	struct rpc_clnt *rpcb_clnt;
+	int error = 0;
+
+	dprintk("RPC:       %sregistering (%u, %u, %d, %u) with local "
+			"rpcbind\n", (port ? "" : "un"),
+			prog, vers, prot, port);
+
+	rpcb_clnt = rpcb_create("localhost", (struct sockaddr *) &sin,
+					IPPROTO_UDP, 2, 1);
+	if (IS_ERR(rpcb_clnt))
+		return PTR_ERR(rpcb_clnt);
+
+	error = rpc_call_sync(rpcb_clnt, &msg, 0);
+
+	if (error < 0)
+		printk(KERN_WARNING "RPC: failed to contact local rpcbind "
+				"server (errno %d).\n", -error);
+	dprintk("RPC:       registration status %d/%d\n", error, *okay);
+
+	return error;
+}
+
+#ifdef CONFIG_ROOT_NFS
+/**
+ * rpcb_getport_external - obtain the port for an RPC service on a given host
+ * @sin: address of remote peer
+ * @prog: RPC program number to bind
+ * @vers: RPC version number to bind
+ * @prot: transport protocol to use to make this request
+ *
+ * Called from outside the RPC client in a synchronous task context.
+ *
+ * For now, this supports only version 2 queries, but is used only by
+ * mount_clnt for NFS_ROOT.
+ */
+int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
+				__u32 vers, int prot)
+{
+	struct rpcbind_args map = {
+		.r_prog		= prog,
+		.r_vers		= vers,
+		.r_prot		= prot,
+		.r_port		= 0,
+	};
+	struct rpc_message msg = {
+		.rpc_proc	= &rpcb_procedures2[RPCB_GETPORT],
+		.rpc_argp	= &map,
+		.rpc_resp	= &map.r_port,
+	};
+	struct rpc_clnt	*rpcb_clnt;
+	char hostname[40];
+	int status;
+
+	dprintk("RPC:       rpcb_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
+			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
+
+	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
+	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
+	if (IS_ERR(rpcb_clnt))
+		return PTR_ERR(rpcb_clnt);
+
+	status = rpc_call_sync(rpcb_clnt, &msg, 0);
+
+	if (status >= 0) {
+		if (map.r_port != 0)
+			return map.r_port;
+		status = -EACCES;
+	}
+	return status;
+}
+#endif
+
+/**
+ * rpcb_getport - obtain the port for a given RPC service on a given host
+ * @task: task that is waiting for portmapper request
+ *
+ * This one can be called for an ongoing RPC request, and can be used in
+ * an async (rpciod) context.
+ */
+void rpcb_getport(struct rpc_task *task)
+{
+	struct rpc_clnt *clnt = task->tk_client;
+	int bind_version;
+	struct rpc_xprt *xprt = task->tk_xprt;
+	struct rpc_clnt	*rpcb_clnt;
+	static struct rpcbind_args *map;
+	struct rpc_task	*child;
+	struct sockaddr addr;
+	int status;
+
+	dprintk("RPC: %5u rpcb_getport(%s, %u, %u, %d)\n",
+			task->tk_pid, clnt->cl_server,
+			clnt->cl_prog, clnt->cl_vers, xprt->prot);
+
+	/* Autobind on cloned rpc clients is discouraged */
+	BUG_ON(clnt->cl_parent != clnt);
+
+	if (xprt_test_and_set_binding(xprt)) {
+		status = -EACCES;		/* tell caller to check again */
+		dprintk("RPC: %5u rpcb_getport waiting for another binder\n",
+				task->tk_pid);
+		goto bailout_nowake;
+	}
+
+	/* Put self on queue before sending rpcbind request, in case
+	 * rpcb_getport_done completes before we return from rpc_run_task */
+	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
+
+	/* Someone else may have bound if we slept */
+	if (xprt_bound(xprt)) {
+		status = 0;
+		dprintk("RPC: %5u rpcb_getport already bound\n", task->tk_pid);
+		goto bailout_nofree;
+	}
+
+	if (rpcb_next_version[xprt->bind_index].rpc_proc == NULL) {
+		xprt->bind_index = 0;
+		status = -EACCES;		/* tell caller to check again */
+		dprintk("RPC: %5u rpcb_getport no more getport versions "
+				"available\n", task->tk_pid);
+		goto bailout_nofree;
+	}
+	bind_version = rpcb_next_version[xprt->bind_index].rpc_vers;
+
+	dprintk("RPC: %5u rpcb_getport trying rpcbind version %u\n",
+			task->tk_pid, bind_version);
+
+	map = kzalloc(sizeof(struct rpcbind_args), GFP_ATOMIC);
+	if (!map) {
+		status = -ENOMEM;
+		dprintk("RPC: %5u rpcb_getport no memory available\n",
+				task->tk_pid);
+		goto bailout_nofree;
+	}
+	map->r_prog = clnt->cl_prog;
+	map->r_vers = clnt->cl_vers;
+	map->r_prot = xprt->prot;
+	map->r_port = 0;
+	map->r_xprt = xprt_get(xprt);
+	map->r_netid = (xprt->prot == IPPROTO_TCP) ? RPCB_NETID_TCP :
+						   RPCB_NETID_UDP;
+	memcpy(&map->r_addr, rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR),
+			sizeof(map->r_addr));
+	map->r_owner = "rpcb";		/* ignored for GETADDR */
+
+	rpc_peeraddr(clnt, (void *)&addr, sizeof(addr));
+	rpcb_clnt = rpcb_create(clnt->cl_server, &addr, xprt->prot, bind_version, 0);
+	if (IS_ERR(rpcb_clnt)) {
+		status = PTR_ERR(rpcb_clnt);
+		dprintk("RPC: %5u rpcb_getport rpcb_create failed, error %ld\n",
+				task->tk_pid, PTR_ERR(rpcb_clnt));
+		goto bailout;
+	}
+
+	child = rpc_run_task(rpcb_clnt, RPC_TASK_ASYNC, &rpcb_getport_ops, map);
+	if (IS_ERR(child)) {
+		status = -EIO;
+		dprintk("RPC: %5u rpcb_getport rpc_run_task failed\n",
+				task->tk_pid);
+		goto bailout;
+	}
+	rpc_put_task(child);
+
+	task->tk_xprt->stat.bind_count++;
+	return;
+
+bailout:
+	kfree(map);
+	xprt_put(xprt);
+bailout_nofree:
+	rpcb_wake_rpcbind_waiters(xprt, status);
+bailout_nowake:
+	task->tk_status = status;
+}
+
+/*
+ * Rpcbind child task calls this callback via tk_exit.
+ */
+static void rpcb_getport_done(struct rpc_task *child, void *data)
+{
+	struct rpcbind_args *map = data;
+	struct rpc_xprt *xprt = map->r_xprt;
+	int status = child->tk_status;
+
+	if (status != -EPROTONOSUPPORT)
+		xprt->bind_index = 0;
+	else
+		xprt->bind_index++;
+
+	if (status < 0) {
+		/* rpcbind server not available on remote host? */
+		xprt->ops->set_port(xprt, 0);
+	} else if (map->r_port == 0) {
+		/* Requested RPC service wasn't registered on remote host */
+		xprt->ops->set_port(xprt, 0);
+		status = -EACCES;
+	} else {
+		/* Succeeded */
+		xprt->ops->set_port(xprt, map->r_port);
+		xprt_set_bound(xprt);
+		status = 0;
+	}
+
+	dprintk("RPC: %5u rpcb_getport_done(status %d, port %u)\n",
+			child->tk_pid, status, map->r_port);
+
+	rpcb_wake_rpcbind_waiters(xprt, status);
+	xprt_put(xprt);
+}
+
+/*
+ * rpcbind version 2 XDR encode/decode routines
+ */
+static int xdr_encode_mapping(struct rpc_rqst *req, __be32 *p,
+				struct rpcbind_args *rpcb)
+{
+	dprintk("RPC:       xdr_encode_mapping(%u, %u, %d, %u)\n",
+		rpcb->r_prog, rpcb->r_vers, rpcb->r_prot, rpcb->r_port);
+	*p++ = htonl(rpcb->r_prog);
+	*p++ = htonl(rpcb->r_vers);
+	*p++ = htonl(rpcb->r_prot);
+	*p++ = htonl(rpcb->r_port);
+
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+	return 0;
+}
+
+static int xdr_decode_getport(struct rpc_rqst *req, __be32 *p,
+				unsigned short *portp)
+{
+	*portp = (unsigned short) ntohl(*p++);
+	return 0;
+}
+
+static int xdr_decode_set(struct rpc_rqst *req, __be32 *p,
+				unsigned int *boolp)
+{
+	*boolp = (unsigned int) ntohl(*p++);
+	return 0;
+}
+
+/*
+ * rpcbind version 3 XDR encode/decode routines
+ */
+static int xdr_encode_getaddr(struct rpc_rqst *req, __be32 *p,
+				struct rpcbind_args *rpcb)
+{
+	dprintk("RPC:       xdr_encode_getaddr(%u, %u, %s)\n",
+		rpcb->r_prog, rpcb->r_vers, rpcb->r_addr);
+	*p++ = htonl(rpcb->r_prog);
+	*p++ = htonl(rpcb->r_vers);
+
+	p = xdr_encode_string(p, rpcb->r_netid);
+	p = xdr_encode_string(p, rpcb->r_addr);
+	p = xdr_encode_string(p, rpcb->r_owner);
+
+	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
+
+	return 0;
+}
+
+static int xdr_decode_getaddr(struct rpc_rqst *req, __be32 *p,
+				unsigned short *portp)
+{
+	char *addr;
+	int addr_len, c, i, f, first, val;
+
+	*portp = 0;
+	addr_len = (unsigned int) ntohl(*p++);
+	addr = (char *)p;
+	val = 0;
+	first = 1;
+	f = 1;
+	for (i = addr_len - 1; i > 0; i--) {
+		c = addr[i];
+		if (c >= '0' && c <= '9') {
+			val += (c - '0') * f;
+			f *= 10;
+		} else if (c == '.') {
+			if (first) {
+				*portp = val;
+				val = first = 0;
+				f = 1;
+			} else {
+				*portp |= (val << 8);
+				break;
+			}
+		}
+	}
+	return 0;
+}
+
+static struct rpc_procinfo rpcb_procedures2[] = {
+	[RPCB_SET] = {
+		.p_proc		= RPCB_SET,
+		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
+		.p_decode	= (kxdrproc_t) xdr_decode_set,
+		.p_bufsiz	= 4,
+		.p_count	= 1,
+	},
+	[RPCB_UNSET] = {
+		.p_proc		= RPCB_UNSET,
+		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
+		.p_decode	= (kxdrproc_t) xdr_decode_set,
+		.p_bufsiz	= 4,
+		.p_count	= 1,
+	},
+	[RPCB_GETADDR] = {
+		.p_proc		= RPCB_GETPORT,
+		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
+		.p_decode	= (kxdrproc_t) xdr_decode_getport,
+		.p_bufsiz	= 4,
+		.p_count	= 1,
+	},
+};
+
+static struct rpc_procinfo rpcb_procedures3[] = {
+	[RPCB_SET] = {
+		.p_proc		= RPCB_SET,
+		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
+		.p_decode	= (kxdrproc_t) xdr_decode_set,
+		.p_bufsiz	= 4,
+		.p_count	= 1,
+	},
+	[RPCB_UNSET] = {
+		.p_proc		= RPCB_UNSET,
+		.p_encode	= (kxdrproc_t) xdr_encode_mapping,
+		.p_decode	= (kxdrproc_t) xdr_decode_set,
+		.p_bufsiz	= 4,
+		.p_count	= 1,
+	},
+	[RPCB_GETADDR] = {
+		.p_proc		= RPCB_GETADDR,
+		.p_encode	= (kxdrproc_t) xdr_encode_getaddr,
+		.p_decode	= (kxdrproc_t) xdr_decode_getaddr,
+		.p_bufsiz	= 36,
+		.p_count	= 1,
+	},
+};
+
+static struct rpc_procinfo rpcb_procedures4[] = {
+	[RPCB_GETVERSADDR] = {
+		.p_proc		= RPCB_GETVERSADDR,
+		.p_encode	= (kxdrproc_t) xdr_encode_getaddr,
+		.p_decode	= (kxdrproc_t) xdr_decode_getaddr,
+		.p_bufsiz	= 36,
+		.p_count	= 1,
+	},
+};
+
+static struct rpcb_info rpcb_next_version[] = {
+	{ 4, &rpcb_procedures4[RPCB_GETVERSADDR] },
+	{ 3, &rpcb_procedures3[RPCB_GETADDR] },
+	{ 2, &rpcb_procedures2[RPCB_GETPORT] },
+	{ 0, NULL },
+};
+
+static struct rpc_version rpcb_version2 = {
+	.number		= 2,
+	.nrprocs	= 4,
+	.procs		= rpcb_procedures2
+};
+
+static struct rpc_version rpcb_version3 = {
+	.number		= 3,
+	.nrprocs	= 4,
+	.procs		= rpcb_procedures3
+};
+
+static struct rpc_version rpcb_version4 = {
+	.number		= 4,
+	.nrprocs	= 10,
+	.procs		= rpcb_procedures4
+};
+
+static struct rpc_version *rpcb_version[] = {
+	NULL,
+	NULL,
+	&rpcb_version2,
+	&rpcb_version3,
+	&rpcb_version4
+};
+
+static struct rpc_stat rpcb_stats;
+
+struct rpc_program rpcb_program = {
+	.name		= "rpcbind",
+	.number		= RPC_BIND_PROGRAM,
+	.nrvers		= ARRAY_SIZE(rpcb_version),
+	.version	= rpcb_version,
+	.stats		= &rpcb_stats,
+};
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 815addd..5261774 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -938,6 +938,7 @@ struct rpc_xprt *xprt_create_transport(i
 	xprt->timer.data = (unsigned long) xprt;
 	xprt->last_used = jiffies;
 	xprt->cwnd = RPC_INITCWND;
+	xprt->bind_index = 0;
 
 	rpc_init_wait_queue(&xprt->binding, "xprt_binding");
 	rpc_init_wait_queue(&xprt->pending, "xprt_pending");

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
