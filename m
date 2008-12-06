From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/27] NSM: Move NSM-related XDR data structures to lockd's
	xdr.h
Date: Fri, 05 Dec 2008 19:01:59 -0500
Message-ID: <20081206000157.24075.95291.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:56595 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbYLFACa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:02:30 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: NSM's XDR data structures are used only in fs/lockd/mon.c,
so move them there.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   14 ++++++++++++++
 include/linux/lockd/sm_inter.h |   20 --------------------
 2 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 3bb71e1..8130883 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,6 +18,20 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
+struct nsm_args {
+	__be32			addr;		/* remote address */
+	u32			prog;		/* RPC callback info */
+	u32			vers;
+	u32			proc;
+
+	char			*mon_name;
+};
+
+struct nsm_res {
+	u32			status;
+	u32			state;
+};
+
 static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 896a5e3..dd9d8a5 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -21,26 +21,6 @@
 #define SM_MAXSTRLEN	1024
 #define SM_PRIV_SIZE	16
 
-/*
- * Arguments for all calls to statd
- */
-struct nsm_args {
-	__be32		addr;		/* remote address */
-	u32		prog;		/* RPC callback info */
-	u32		vers;
-	u32		proc;
-
-	char *		mon_name;
-};
-
-/*
- * Result returned by statd
- */
-struct nsm_res {
-	u32		status;
-	u32		state;
-};
-
 extern int	nsm_local_state;
 
 #endif /* LINUX_LOCKD_SM_INTER_H */

