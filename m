From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/15] SUNRPC: remove old portmapper
Date: Wed, 24 Jan 2007 14:20:13 -0500
Message-ID: <20070124192013.31133.81398.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ngk-0001AF-GF
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:42 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9ngk-0004Sc-9V
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:44 -0800
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

net/sunrpc/pmap_clnt.c has been replaced by net/sunrpc/rpcb_clnt.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h     |    3 
 include/linux/sunrpc/debug.h    |    1 
 include/linux/sunrpc/msg_prot.h |    4 
 net/sunrpc/Makefile             |    2 
 net/sunrpc/pmap_clnt.c          |  381 ---------------------------------------
 5 files changed, 1 insertions(+), 390 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 702baef..a34737a 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -121,8 +121,6 @@ struct rpc_clnt *rpc_clone_client(struct
 int		rpc_shutdown_client(struct rpc_clnt *);
 int		rpc_destroy_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
-void		rpc_getport(struct rpc_task *);
-int		rpc_register(u32, u32, int, unsigned short, int *);
 int		rpcb_register(u32, u32, int, unsigned short, int *);
 void		rpcb_getport(struct rpc_task *);
 
@@ -146,7 +144,6 @@ char *		rpc_peeraddr2str(struct rpc_clnt
 /*
  * Helper function for NFSroot support
  */
-int		rpc_getport_external(struct sockaddr_in *, __u32, __u32, int);
 int		rpcb_getport_external(struct sockaddr_in *, __u32, __u32, int);
 
 #endif /* __KERNEL__ */
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 7b11c74..a3754d9 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -17,7 +17,6 @@ #define RPCDBG_CALL		0x0002
 #define RPCDBG_DEBUG		0x0004
 #define RPCDBG_NFS		0x0008
 #define RPCDBG_AUTH		0x0010
-#define RPCDBG_PMAP		0x0020
 #define RPCDBG_BIND		0x0020
 #define RPCDBG_SCHED		0x0040
 #define RPCDBG_TRANS		0x0080
diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 606cb21..784d4c3 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -78,10 +78,6 @@ enum rpc_auth_stat {
 	RPCSEC_GSS_CTXPROBLEM = 14
 };
 
-#define RPC_PMAP_PROGRAM	100000
-#define RPC_PMAP_VERSION	2
-#define RPC_PMAP_PORT		111
-
 #define RPC_MAXNETNAMELEN	256
 
 /*
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 3417a1e..8ebfc4d 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
 sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    auth.o auth_null.o auth_unix.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
-	    pmap_clnt.o rpcb_clnt.o timer.o xdr.o \
+	    rpcb_clnt.o timer.o xdr.o \
 	    sunrpc_syms.o cache.o rpc_pipe.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
deleted file mode 100644
index 8d9e780..0000000
--- a/net/sunrpc/pmap_clnt.c
+++ /dev/null
@@ -1,381 +0,0 @@
-/*
- * linux/net/sunrpc/pmap_clnt.c
- *
- * In-kernel RPC portmapper client.
- *
- * Portmapper supports version 2 of the rpcbind protocol (RFC 1833).
- *
- * Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
- */
-
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/kernel.h>
-#include <linux/errno.h>
-#include <linux/uio.h>
-#include <linux/in.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/sunrpc/sched.h>
-
-#ifdef RPC_DEBUG
-# define RPCDBG_FACILITY	RPCDBG_PMAP
-#endif
-
-#define PMAP_SET		1
-#define PMAP_UNSET		2
-#define PMAP_GETPORT		3
-
-struct portmap_args {
-	u32			pm_prog;
-	u32			pm_vers;
-	u32			pm_prot;
-	unsigned short		pm_port;
-	struct rpc_xprt *	pm_xprt;
-};
-
-static struct rpc_procinfo	pmap_procedures[];
-static struct rpc_clnt *	pmap_create(char *, struct sockaddr_in *, int, int);
-static void			pmap_getport_done(struct rpc_task *, void *);
-static struct rpc_program	pmap_program;
-
-static void pmap_getport_prepare(struct rpc_task *task, void *calldata)
-{
-	struct portmap_args *map = calldata;
-	struct rpc_message msg = {
-		.rpc_proc	= &pmap_procedures[PMAP_GETPORT],
-		.rpc_argp	= map,
-		.rpc_resp	= &map->pm_port,
-	};
-
-	rpc_call_setup(task, &msg, 0);
-}
-
-static inline struct portmap_args *pmap_map_alloc(void)
-{
-	return kmalloc(sizeof(struct portmap_args), GFP_NOFS);
-}
-
-static inline void pmap_map_free(struct portmap_args *map)
-{
-	kfree(map);
-}
-
-static void pmap_map_release(void *data)
-{
-	pmap_map_free(data);
-}
-
-static const struct rpc_call_ops pmap_getport_ops = {
-	.rpc_call_prepare	= pmap_getport_prepare,
-	.rpc_call_done		= pmap_getport_done,
-	.rpc_release		= pmap_map_release,
-};
-
-static inline void pmap_wake_portmap_waiters(struct rpc_xprt *xprt, int status)
-{
-	xprt_clear_binding(xprt);
-	rpc_wake_up_status(&xprt->binding, status);
-}
-
-/**
- * rpc_getport - obtain the port for a given RPC service on a given host
- * @task: task that is waiting for portmapper request
- *
- * This one can be called for an ongoing RPC request, and can be used in
- * an async (rpciod) context.
- */
-void rpc_getport(struct rpc_task *task)
-{
-	struct rpc_clnt *clnt = task->tk_client;
-	struct rpc_xprt *xprt = task->tk_xprt;
-	struct sockaddr_in addr;
-	struct portmap_args *map;
-	struct rpc_clnt	*pmap_clnt;
-	struct rpc_task *child;
-	int status;
-
-	dprintk("RPC: %5u rpc_getport(%s, %u, %u, %d)\n",
-			task->tk_pid, clnt->cl_server,
-			clnt->cl_prog, clnt->cl_vers, xprt->prot);
-
-	/* Autobind on cloned rpc clients is discouraged */
-	BUG_ON(clnt->cl_parent != clnt);
-
-	status = -EACCES;		/* tell caller to check again */
-	if (xprt_test_and_set_binding(xprt))
-		goto bailout_nowake;
-
-	/* Put self on queue before sending rpcbind request, in case
-	 * pmap_getport_done completes before we return from rpc_run_task */
-	rpc_sleep_on(&xprt->binding, task, NULL, NULL);
-
-	/* Someone else may have bound if we slept */
-	status = 0;
-	if (xprt_bound(xprt))
-		goto bailout_nofree;
-
-	status = -ENOMEM;
-	map = pmap_map_alloc();
-	if (!map)
-		goto bailout_nofree;
-	map->pm_prog = clnt->cl_prog;
-	map->pm_vers = clnt->cl_vers;
-	map->pm_prot = xprt->prot;
-	map->pm_port = 0;
-	map->pm_xprt = xprt_get(xprt);
-
-	rpc_peeraddr(clnt, (struct sockaddr *) &addr, sizeof(addr));
-	pmap_clnt = pmap_create(clnt->cl_server, &addr, map->pm_prot, 0);
-	status = PTR_ERR(pmap_clnt);
-	if (IS_ERR(pmap_clnt))
-		goto bailout;
-
-	status = -EIO;
-	child = rpc_run_task(pmap_clnt, RPC_TASK_ASYNC, &pmap_getport_ops, map);
-	if (IS_ERR(child))
-		goto bailout;
-	rpc_put_task(child);
-
-	task->tk_xprt->stat.bind_count++;
-	return;
-
-bailout:
-	pmap_map_free(map);
-	xprt_put(xprt);
-bailout_nofree:
-	pmap_wake_portmap_waiters(xprt, status);
-bailout_nowake:
-	task->tk_status = status;
-}
-
-#ifdef CONFIG_ROOT_NFS
-/**
- * rpc_getport_external - obtain the port for a given RPC service on a given host
- * @sin: address of remote peer
- * @prog: RPC program number to bind
- * @vers: RPC version number to bind
- * @prot: transport protocol to use to make this request
- *
- * This one is called from outside the RPC client in a synchronous task context.
- */
-int rpc_getport_external(struct sockaddr_in *sin, __u32 prog, __u32 vers, int prot)
-{
-	struct portmap_args map = {
-		.pm_prog	= prog,
-		.pm_vers	= vers,
-		.pm_prot	= prot,
-		.pm_port	= 0
-	};
-	struct rpc_message msg = {
-		.rpc_proc	= &pmap_procedures[PMAP_GETPORT],
-		.rpc_argp	= &map,
-		.rpc_resp	= &map.pm_port,
-	};
-	struct rpc_clnt	*pmap_clnt;
-	char		hostname[32];
-	int		status;
-
-	dprintk("RPC:       rpc_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
-			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
-
-	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
-	pmap_clnt = pmap_create(hostname, sin, prot, 0);
-	if (IS_ERR(pmap_clnt))
-		return PTR_ERR(pmap_clnt);
-
-	/* Setup the call info struct */
-	status = rpc_call_sync(pmap_clnt, &msg, 0);
-
-	if (status >= 0) {
-		if (map.pm_port != 0)
-			return map.pm_port;
-		status = -EACCES;
-	}
-	return status;
-}
-#endif
-
-/*
- * Portmapper child task invokes this callback via tk_exit.
- */
-static void pmap_getport_done(struct rpc_task *child, void *data)
-{
-	struct portmap_args *map = data;
-	struct rpc_xprt *xprt = map->pm_xprt;
-	int status = child->tk_status;
-
-	if (status < 0) {
-		/* Portmapper not available */
-		xprt->ops->set_port(xprt, 0);
-	} else if (map->pm_port == 0) {
-		/* Requested RPC service wasn't registered */
-		xprt->ops->set_port(xprt, 0);
-		status = -EACCES;
-	} else {
-		/* Succeeded */
-		xprt->ops->set_port(xprt, map->pm_port);
-		xprt_set_bound(xprt);
-		status = 0;
-	}
-
-	dprintk("RPC: %5u pmap_getport_done(status %d, port %u)\n",
-			child->tk_pid, status, map->pm_port);
-
-	pmap_wake_portmap_waiters(xprt, status);
-	xprt_put(xprt);
-}
-
-/**
- * rpc_register - set or unset a port registration with the local portmapper
- * @prog: RPC program number to bind
- * @vers: RPC version number to bind
- * @prot: transport protocol to use to make this request
- * @port: port value to register
- * @okay: result code
- *
- * port == 0 means unregister, port != 0 means register.
- */
-int rpc_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
-{
-	struct sockaddr_in	sin = {
-		.sin_family	= AF_INET,
-		.sin_addr.s_addr = htonl(INADDR_LOOPBACK),
-	};
-	struct portmap_args	map = {
-		.pm_prog	= prog,
-		.pm_vers	= vers,
-		.pm_prot	= prot,
-		.pm_port	= port,
-	};
-	struct rpc_message msg = {
-		.rpc_proc	= &pmap_procedures[port ? PMAP_SET : PMAP_UNSET],
-		.rpc_argp	= &map,
-		.rpc_resp	= okay,
-	};
-	struct rpc_clnt		*pmap_clnt;
-	int error = 0;
-
-	dprintk("RPC:       registering (%u, %u, %d, %u) with portmapper.\n",
-			prog, vers, prot, port);
-
-	pmap_clnt = pmap_create("localhost", &sin, IPPROTO_UDP, 1);
-	if (IS_ERR(pmap_clnt)) {
-		error = PTR_ERR(pmap_clnt);
-		dprintk("RPC:       couldn't create pmap client. Error = %d\n",
-				error);
-		return error;
-	}
-
-	error = rpc_call_sync(pmap_clnt, &msg, 0);
-
-	if (error < 0) {
-		printk(KERN_WARNING
-			"RPC: failed to contact portmap (errno %d).\n",
-			error);
-	}
-	dprintk("RPC:       registration status %d/%d\n", error, *okay);
-
-	/* Client deleted automatically because cl_oneshot == 1 */
-	return error;
-}
-
-static struct rpc_clnt *pmap_create(char *hostname, struct sockaddr_in *srvaddr, int proto, int privileged)
-{
-	struct rpc_create_args args = {
-		.protocol	= proto,
-		.address	= (struct sockaddr *)srvaddr,
-		.addrsize	= sizeof(*srvaddr),
-		.servername	= hostname,
-		.program	= &pmap_program,
-		.version	= RPC_PMAP_VERSION,
-		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= (RPC_CLNT_CREATE_ONESHOT |
-				   RPC_CLNT_CREATE_NOPING),
-	};
-
-	srvaddr->sin_port = htons(RPC_PMAP_PORT);
-	if (!privileged)
-		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
-	return rpc_create(&args);
-}
-
-/*
- * XDR encode/decode functions for PMAP
- */
-static int xdr_encode_mapping(struct rpc_rqst *req, __be32 *p, struct portmap_args *map)
-{
-	dprintk("RPC:       xdr_encode_mapping(%u, %u, %u, %u)\n",
-			map->pm_prog, map->pm_vers,
-			map->pm_prot, map->pm_port);
-	*p++ = htonl(map->pm_prog);
-	*p++ = htonl(map->pm_vers);
-	*p++ = htonl(map->pm_prot);
-	*p++ = htonl(map->pm_port);
-
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int xdr_decode_port(struct rpc_rqst *req, __be32 *p, unsigned short *portp)
-{
-	*portp = (unsigned short) ntohl(*p++);
-	return 0;
-}
-
-static int xdr_decode_bool(struct rpc_rqst *req, __be32 *p, unsigned int *boolp)
-{
-	*boolp = (unsigned int) ntohl(*p++);
-	return 0;
-}
-
-static struct rpc_procinfo	pmap_procedures[] = {
-[PMAP_SET] = {
-	  .p_proc		= PMAP_SET,
-	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,	
-	  .p_decode		= (kxdrproc_t) xdr_decode_bool,
-	  .p_bufsiz		= 4,
-	  .p_count		= 1,
-	  .p_statidx		= PMAP_SET,
-	  .p_name		= "SET",
-	},
-[PMAP_UNSET] = {
-	  .p_proc		= PMAP_UNSET,
-	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,	
-	  .p_decode		= (kxdrproc_t) xdr_decode_bool,
-	  .p_bufsiz		= 4,
-	  .p_count		= 1,
-	  .p_statidx		= PMAP_UNSET,
-	  .p_name		= "UNSET",
-	},
-[PMAP_GETPORT] = {
-	  .p_proc		= PMAP_GETPORT,
-	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,
-	  .p_decode		= (kxdrproc_t) xdr_decode_port,
-	  .p_bufsiz		= 4,
-	  .p_count		= 1,
-	  .p_statidx		= PMAP_GETPORT,
-	  .p_name		= "GETPORT",
-	},
-};
-
-static struct rpc_version	pmap_version2 = {
-	.number		= 2,
-	.nrprocs	= 4,
-	.procs		= pmap_procedures
-};
-
-static struct rpc_version *	pmap_version[] = {
-	NULL,
-	NULL,
-	&pmap_version2
-};
-
-static struct rpc_stat		pmap_stats;
-
-static struct rpc_program	pmap_program = {
-	.name		= "portmap",
-	.number		= RPC_PMAP_PROGRAM,
-	.nrvers		= ARRAY_SIZE(pmap_version),
-	.version	= pmap_version,
-	.stats		= &pmap_stats,
-};

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
