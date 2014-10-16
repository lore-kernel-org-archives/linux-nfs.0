Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:44064 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbaJPTjp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:39:45 -0400
Received: by mail-ig0-f181.google.com with SMTP id r10so282320igi.2
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:39:45 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id p5sm14831654iga.5.2014.10.16.12.39.44
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:39:44 -0700 (PDT)
Subject: [PATCH v1 11/16] NFS: Clean up nfs4_init_callback()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:39:44 -0400
Message-ID: <20141016193943.13414.42326.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
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
 

