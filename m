Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34244 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaKIBP2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:15:28 -0500
Subject: [PATCH v2 10/10] NFS: Clean up nfs4_init_callback()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:15:26 -0500
Message-ID: <20141109011526.8806.76442.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_init_callback() is never invoked for NFS versions other than 4.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4client.c |   31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ffdb28d..5f4b818 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -241,28 +241,25 @@ void nfs4_free_client(struct nfs_client *clp)
  */
 static int nfs4_init_callback(struct nfs_client *clp)
 {
+	struct rpc_xprt *xprt;
 	int error;
 
-	if (clp->rpc_ops->version == 4) {
-		struct rpc_xprt *xprt;
+	xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
 
-		xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
-
-		if (nfs4_has_session(clp)) {
-			error = xprt_setup_backchannel(xprt,
-						NFS41_BC_MIN_CALLBACKS);
-			if (error < 0)
-				return error;
-		}
-
-		error = nfs_callback_up(clp->cl_mvops->minor_version, xprt);
-		if (error < 0) {
-			dprintk("%s: failed to start callback. Error = %d\n",
-				__func__, error);
+	if (nfs4_has_session(clp)) {
+		error = xprt_setup_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
+		if (error < 0)
 			return error;
-		}
-		__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
 	}
+
+	error = nfs_callback_up(clp->cl_mvops->minor_version, xprt);
+	if (error < 0) {
+		dprintk("%s: failed to start callback. Error = %d\n",
+			__func__, error);
+		return error;
+	}
+	__set_bit(NFS_CS_CALLBACK, &clp->cl_res_state);
+
 	return 0;
 }
 

