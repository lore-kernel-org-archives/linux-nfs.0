From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/21] SUNRPC: Rename rpcb_getport_external routine
Date: Sun, 01 Jul 2007 12:13:12 -0400
Message-ID: <20070701161312.2786.69793.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I524U-0004Yy-Gq
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:50 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I524X-0005GN-Qs
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:50 -0700
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

In preparation for handling NFS mount option parsing in the kernel,
rename rpcb_getport_external as rpcb_get_port_sync, and make it available
always (instead of only when CONFIG_ROOT_NFS is enabled).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c            |    2 +-
 include/linux/sunrpc/clnt.h |    7 ++-----
 net/sunrpc/rpcb_clnt.c      |   21 +++++++++++----------
 3 files changed, 14 insertions(+), 16 deletions(-)

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
index 097984b..b28d919 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -120,8 +120,10 @@ struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
+
 int		rpcb_register(u32, u32, int, unsigned short, int *);
 void		rpcb_getport(struct rpc_task *);
+int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
 
 void		rpc_call_setup(struct rpc_task *, struct rpc_message *, int);
 
@@ -141,10 +143,5 @@ void		rpc_force_rebind(struct rpc_clnt *);
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
index af630e2..23dc65a 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -12,6 +12,8 @@
  *  Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
  */
 
+#include <linux/module.h>
+
 #include <linux/types.h>
 #include <linux/socket.h>
 #include <linux/kernel.h>
@@ -247,21 +249,20 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
 	return error;
 }
 
-#ifdef CONFIG_ROOT_NFS
 /**
- * rpcb_getport_external - obtain the port for an RPC service on a given host
+ * rpcb_getport_sync - obtain the port for an RPC service on a given host
  * @sin: address of remote peer
  * @prog: RPC program number to bind
  * @vers: RPC version number to bind
  * @prot: transport protocol to use to make this request
  *
  * Called from outside the RPC client in a synchronous task context.
+ * Uses default timeout parameters specified by underlying transport.
  *
- * For now, this supports only version 2 queries, but is used only by
- * mount_clnt for NFS_ROOT.
+ * XXX: Needs to support IPv6, and rpcbind versions 3 and 4
  */
-int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
-				__u32 vers, int prot)
+int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
+		      __u32 vers, int prot)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
@@ -278,10 +279,10 @@ int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
 	char hostname[40];
 	int status;
 
-	dprintk("RPC:       rpcb_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
-			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
+	dprintk("RPC:       %s(" NIPQUAD_FMT ", %u, %u, %d)\n",
+		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
-	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
+	sprintf(hostname, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
 	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin, prot, 2, 0);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
@@ -296,7 +297,7 @@ int rpcb_getport_external(struct sockaddr_in *sin, __u32 prog,
 	}
 	return status;
 }
-#endif
+EXPORT_SYMBOL_GPL(rpcb_getport_sync);
 
 /**
  * rpcb_getport - obtain the port for a given RPC service on a given host


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
