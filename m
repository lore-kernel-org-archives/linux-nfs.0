From: Andy Adamson <andros@netapp.com>
Subject: [PATCH_V3 7/7] NFS only set bc_xprt upon success
Date: Mon, 13 Dec 2010 15:19:45 -0500
Message-ID: <1292271585-3038-8-git-send-email-andros@netapp.com>
References: <1292271585-3038-1-git-send-email-andros@netapp.com>
 <1292271585-3038-2-git-send-email-andros@netapp.com>
 <1292271585-3038-3-git-send-email-andros@netapp.com>
 <1292271585-3038-4-git-send-email-andros@netapp.com>
 <1292271585-3038-5-git-send-email-andros@netapp.com>
 <1292271585-3038-6-git-send-email-andros@netapp.com>
 <1292271585-3038-7-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35978 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755151Ab0LMUUG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 15:20:06 -0500
In-Reply-To: <1292271585-3038-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid a double svc_sock_destroy.
nfs41_callback_up destroys the bc_xprt upon failure. nfs_callback_up calls
svc_destroy on failure which also calls svc_sock_destroy on the bc_xprt.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index dc2ead1..8129511 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -215,7 +215,6 @@ nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 	 * Save the svc_serv in the transport so that it can
 	 * be referenced when the session backchannel is initialized
 	 */
-	serv->bc_xprt = bc_xprt;
 	xprt->bc_serv = serv;
 
 	/* socket is shared with the fore channel */
@@ -227,6 +226,8 @@ nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 	rqstp = svc_prepare_thread(serv, &serv->sv_pools[0]);
 	if (IS_ERR(rqstp))
 		svc_sock_destroy(bc_xprt);
+	else
+		serv->bc_xprt = bc_xprt;
 out:
 	dprintk("--> %s return %p\n", __func__, rqstp);
 	return rqstp;
-- 
1.6.6

