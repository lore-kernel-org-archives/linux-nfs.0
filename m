From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/21] SUNRPC: relocate the creation of
	socket-specific tunables
Date: Thu, 16 Nov 2006 15:04:43 -0500
Message-ID: <20061116200443.32549.65484.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1k-0006vU-Fk
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:04 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1l-0004v0-5z
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:05 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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

Clean-up:

The RPC client currently creates some sysctls that are specific to the
socket transport.  Move those entirely into xprtsock.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/sysctl.c   |   50 -----------------------
 net/sunrpc/xprtsock.c |  107 ++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 104 insertions(+), 53 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index d89b048..82b2752 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -18,7 +18,6 @@ #include <asm/uaccess.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/stats.h>
-#include <linux/sunrpc/xprt.h>
 
 /*
  * Declare the debug flags here
@@ -119,11 +118,6 @@ done:
 }
 
 
-static unsigned int min_slot_table_size = RPC_MIN_SLOT_TABLE;
-static unsigned int max_slot_table_size = RPC_MAX_SLOT_TABLE;
-static unsigned int xprt_min_resvport_limit = RPC_MIN_RESVPORT;
-static unsigned int xprt_max_resvport_limit = RPC_MAX_RESVPORT;
-
 static ctl_table debug_table[] = {
 	{
 		.ctl_name	= CTL_RPCDEBUG,
@@ -157,50 +151,6 @@ static ctl_table debug_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dodebug
 	}, 
-	{
-		.ctl_name	= CTL_SLOTTABLE_UDP,
-		.procname	= "udp_slot_table_entries",
-		.data		= &xprt_udp_slot_table_entries,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &min_slot_table_size,
-		.extra2		= &max_slot_table_size
-	},
-	{
-		.ctl_name	= CTL_SLOTTABLE_TCP,
-		.procname	= "tcp_slot_table_entries",
-		.data		= &xprt_tcp_slot_table_entries,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &min_slot_table_size,
-		.extra2		= &max_slot_table_size
-	},
-	{
-		.ctl_name	= CTL_MIN_RESVPORT,
-		.procname	= "min_resvport",
-		.data		= &xprt_min_resvport,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &xprt_min_resvport_limit,
-		.extra2		= &xprt_max_resvport_limit
-	},
-	{
-		.ctl_name	= CTL_MAX_RESVPORT,
-		.procname	= "max_resvport",
-		.data		= &xprt_max_resvport,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &xprt_min_resvport_limit,
-		.extra2		= &xprt_max_resvport_limit
-	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fd8e39e..f000595 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -46,6 +46,92 @@ unsigned int xprt_min_resvport = RPC_DEF
 unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
 /*
+ * We can register our own files under /proc/sys/sunrpc by
+ * calling register_sysctl_table() again.  The files in that
+ * directory become the union of all files registered there.
+ *
+ * We simply need to make sure that we don't collide with
+ * someone else's file names!
+ */
+
+#ifdef RPC_DEBUG
+
+static unsigned int min_slot_table_size = RPC_MIN_SLOT_TABLE;
+static unsigned int max_slot_table_size = RPC_MAX_SLOT_TABLE;
+static unsigned int xprt_min_resvport_limit = RPC_MIN_RESVPORT;
+static unsigned int xprt_max_resvport_limit = RPC_MAX_RESVPORT;
+
+static struct ctl_table_header *sunrpc_table_header;
+
+/*
+ * FIXME: changing the UDP slot table size should also resize the UDP
+ *        socket buffers for existing UDP transports
+ */
+static ctl_table xs_tunables_table[] = {
+	{
+		.ctl_name	= CTL_SLOTTABLE_UDP,
+		.procname	= "udp_slot_table_entries",
+		.data		= &xprt_udp_slot_table_entries,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &min_slot_table_size,
+		.extra2		= &max_slot_table_size
+	},
+	{
+		.ctl_name	= CTL_SLOTTABLE_TCP,
+		.procname	= "tcp_slot_table_entries",
+		.data		= &xprt_tcp_slot_table_entries,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &min_slot_table_size,
+		.extra2		= &max_slot_table_size
+	},
+	{
+		.ctl_name	= CTL_MIN_RESVPORT,
+		.procname	= "min_resvport",
+		.data		= &xprt_min_resvport,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &xprt_min_resvport_limit,
+		.extra2		= &xprt_max_resvport_limit
+	},
+	{
+		.ctl_name	= CTL_MAX_RESVPORT,
+		.procname	= "max_resvport",
+		.data		= &xprt_max_resvport,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &xprt_min_resvport_limit,
+		.extra2		= &xprt_max_resvport_limit
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+static ctl_table sunrpc_table[] = {
+	{
+		.ctl_name	= CTL_SUNRPC,
+		.procname	= "sunrpc",
+		.mode		= 0555,
+		.child		= xs_tunables_table
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+#endif
+
+/*
  * How many times to try sending a request on a socket before waiting
  * for the socket buffer to clear.
  */
@@ -1514,19 +1600,34 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 }
 
 /**
- * init_socket_xprt - stub
+ * init_socket_xprt - set up xprtsock's sysctls
  *
  */
 int init_socket_xprt(void)
 {
+#ifdef RPC_DEBUG
+	if (!sunrpc_table_header) {
+		sunrpc_table_header = register_sysctl_table(sunrpc_table, 1);
+#ifdef CONFIG_PROC_FS
+		if (sunrpc_table[0].de)
+			sunrpc_table[0].de->owner = THIS_MODULE;
+#endif
+	}
+#endif
+
 	return 0;
 }
 
 /**
- * cleanup_socket_xprt - stub
+ * cleanup_socket_xprt - remove xprtsock's sysctls
  *
  */
 void cleanup_socket_xprt(void)
 {
-	return;
+#ifdef RPC_DEBUG
+	if (sunrpc_table_header) {
+		unregister_sysctl_table(sunrpc_table_header);
+		sunrpc_table_header = NULL;
+	}
+#endif
 }

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
