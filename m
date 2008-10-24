From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/14] NSM: Move NSM-related XDR data structures to lockd's
	xdr.h
Date: Fri, 24 Oct 2008 14:10:24 -0400
Message-ID: <20081024181024.23810.95756.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:27953 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbYJXSLR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:17 -0400
Received: from rgminet15.oracle.com (mail-router.oracle.com [148.87.113.117])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id m9OIBIPT018760
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 18:11:19 GMT
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id m9O9GhCu027540
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 18:11:14 GMT
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIAOZe023937
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:10:24 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index d48ae14..db650cf 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -22,6 +22,20 @@ static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
 
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
 /*
  * Local NSM state
  */
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

