From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 11/19] SUNRPC: rearrange RPC sockets definitions
Date: Mon, 10 Sep 2007 13:47:31 -0400
Message-ID: <EXNANE01HsjCGvseE4D000004ba@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnas-0003T7-EU
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:02:42 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnaw-0007bw-VP
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:02:47 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI2eVd021489
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:02:41 -0700 (PDT)
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

SUNRPC: rearrange RPC sockets definitions

To prepare for including non-sockets-based RPC transports, move the
sockets-dependent definitions into their own file.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 include/linux/sunrpc/xprt.h     |   22 ----------------------
 include/linux/sunrpc/xprtsock.h |   40 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sunrpc_syms.c        |    2 +-
 net/sunrpc/xprtsock.c           |    1 +
 4 files changed, 42 insertions(+), 23 deletions(-)

Index: kernel/include/linux/sunrpc/xprt.h
===================================================================
--- kernel.orig/include/linux/sunrpc/xprt.h
+++ kernel/include/linux/sunrpc/xprt.h
@@ -19,25 +19,11 @@
 
 #ifdef __KERNEL__
 
-extern unsigned int xprt_udp_slot_table_entries;
-extern unsigned int xprt_tcp_slot_table_entries;
-
 #define RPC_MIN_SLOT_TABLE	(2U)
 #define RPC_DEF_SLOT_TABLE	(16U)
 #define RPC_MAX_SLOT_TABLE	(128U)
 
 /*
- * Parameters for choosing a free port
- */
-extern unsigned int xprt_min_resvport;
-extern unsigned int xprt_max_resvport;
-
-#define RPC_MIN_RESVPORT	(1U)
-#define RPC_MAX_RESVPORT	(65535U)
-#define RPC_DEF_MIN_RESVPORT	(665U)
-#define RPC_DEF_MAX_RESVPORT	(1023U)
-
-/*
  * This describes a timeout strategy
  */
 struct rpc_timeout {
@@ -263,14 +249,6 @@ void			xprt_release_rqst_cong(struct rpc
 void			xprt_disconnect(struct rpc_xprt *xprt);
 
 /*
- * Socket transport setup operations
- */
-struct rpc_xprt		*xs_setup_udp(struct xprt_create *args);
-struct rpc_xprt		*xs_setup_tcp(struct xprt_create *args);
-int			init_socket_xprt(void);
-void			cleanup_socket_xprt(void);
-
-/*
  * Reserved bit positions in xprt->state
  */
 #define XPRT_LOCKED		(0)
Index: kernel/include/linux/sunrpc/xprtsock.h
===================================================================
--- /dev/null
+++ kernel/include/linux/sunrpc/xprtsock.h
@@ -0,0 +1,40 @@
+/*
+ *  linux/include/linux/sunrpc/xprtsock.h
+ *
+ *  Declarations for the RPC transport socket provider.
+ */
+
+#ifndef _LINUX_SUNRPC_XPRTSOCK_H
+#define _LINUX_SUNRPC_XPRTSOCK_H
+
+#ifdef __KERNEL__
+
+/*
+ * Socket transport setup operations
+ */
+struct rpc_xprt *xs_setup_udp(struct xprt_create *args);
+struct rpc_xprt *xs_setup_tcp(struct xprt_create *args);
+
+int		init_socket_xprt(void);
+void		cleanup_socket_xprt(void);
+
+/*
+ * RPC slot table sizes for UDP, TCP transports
+ */
+extern unsigned int xprt_udp_slot_table_entries;
+extern unsigned int xprt_tcp_slot_table_entries;
+
+/*
+ * Parameters for choosing a free port
+ */
+extern unsigned int xprt_min_resvport;
+extern unsigned int xprt_max_resvport;
+
+#define RPC_MIN_RESVPORT	(1U)
+#define RPC_MAX_RESVPORT	(65535U)
+#define RPC_DEF_MIN_RESVPORT	(665U)
+#define RPC_DEF_MAX_RESVPORT	(1023U)
+
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_SUNRPC_XPRTSOCK_H */
Index: kernel/net/sunrpc/xprtsock.c
===================================================================
--- kernel.orig/net/sunrpc/xprtsock.c
+++ kernel/net/sunrpc/xprtsock.c
@@ -32,6 +32,7 @@
 #include <linux/tcp.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/xprtsock.h>
 #include <linux/file.h>
 
 #include <net/sock.h>
Index: kernel/net/sunrpc/sunrpc_syms.c
===================================================================
--- kernel.orig/net/sunrpc/sunrpc_syms.c
+++ kernel/net/sunrpc/sunrpc_syms.c
@@ -20,7 +20,7 @@
 #include <linux/sunrpc/auth.h>
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
-
+#include <linux/sunrpc/xprtsock.h>
 
 /* RPC scheduler */
 EXPORT_SYMBOL(rpc_execute);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
