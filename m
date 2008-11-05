From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/18] NSM: Move NSM-related XDR data structures to lockd's
	xdr.h
Date: Wed, 05 Nov 2008 12:20:12 -0500
Message-ID: <20081105172012.6773.13450.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35832 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbYKERUb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:20:31 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: NSM's XDR data structures are used only in fs/lockd/mon.c,
so move them out of the public header sm_inter.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   14 ++++++++++++++
 include/linux/lockd/sm_inter.h |   20 --------------------
 2 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4ffd556..6fafc06 100644
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
 static struct rpc_program	nsm_program;
 static				LIST_HEAD(nsm_handles);
 static				DEFINE_SPINLOCK(nsm_lock);
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index f75d3ea..29f0206 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -21,24 +21,4 @@
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
 #endif /* LINUX_LOCKD_SM_INTER_H */

