From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 73/85] nfs41: Setup the backchannel
Date: Mon, 10 Nov 2008 22:31:15 +0200
Message-ID: <1226349075-9669-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60064 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbYKJUbW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:31:22 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

The NFS v4.1 callback service has already been setup, and
rpc_xprt->serv points to the svc_serv structure describing it.
Invoke the xprt_setup_backchannel() initialization to pre-
allocate the necessary backchannel structures.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dc5b6e7..2a24d43 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -39,6 +39,7 @@
 #include <linux/nfs_xdr.h>
 #if defined(CONFIG_NFS_V4_1)
 #include <linux/nfs41_session_recovery.h>
+#include <linux/sunrpc/bc_xprt.h>
 #endif /* CONFIG_NFS_V4_1 */
 
 #include <asm/system.h>
@@ -1125,7 +1126,7 @@ error:
 }
 
 /*
- * Allocate and initialize a session if required
+ * Allocate and initialize a session if required, including its backchannel.
  */
 int nfs4_init_session(struct nfs_client *clp, struct rpc_clnt *clnt)
 {
@@ -1145,6 +1146,12 @@ int nfs4_init_session(struct nfs_client *clp, struct rpc_clnt *clnt)
 		else {
 			session->clnt = clnt;
 			session->clp = clp;
+
+			error = xprt_setup_backchannel(clnt->cl_xprt,
+					NFS41_BC_MIN_CALLBACKS);
+			if (error < 0)
+				/* nfs4_put session sets the session to NULL */
+				nfs4_put_session(&session);
 		}
 		clp->cl_session = session;
 	}
-- 
1.6.0.2

