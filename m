Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26569 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753999Ab0K3W3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 17:29:05 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/5] NFS dont free shared socket on backchannel put xprt
Date: Tue, 30 Nov 2010 15:31:07 -0500
Message-Id: <1291149071-2026-2-git-send-email-andros@netapp.com>
In-Reply-To: <1291149071-2026-1-git-send-email-andros@netapp.com>
References: <1291149071-2026-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Fixes this bug:
fedora-64 kernel: Invoking bc_svc_procass()
fedora-64 kernel: nfs_callback_authenticate SVC_DROP
fedora-64 kernel: BUG: unable to handle kernel NULL pointer dereference at 0000000000000018 IP: [<ffffffffa0156140>] svc_sock_free+0x32/0x56 [sunrpc]

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback.c               |    3 +++
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc_xprt.c           |    3 ++-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 93a8b3b..023a9eb 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -193,6 +193,9 @@ nfs41_callback_up(struct svc_serv *serv, struct rpc_xprt *xprt)
 	serv->bc_xprt = bc_xprt;
 	xprt->bc_serv = serv;
 
+	/* socket is shared with the fore channel */
+	set_bit(XPT_SHARE_SOCK, &bc_xprt->xpt_flags);
+
 	INIT_LIST_HEAD(&serv->sv_cb_list);
 	spin_lock_init(&serv->sv_cb_lock);
 	init_waitqueue_head(&serv->sv_cb_waitq);
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index aea0d43..600c669 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -62,6 +62,7 @@ struct svc_xprt {
 #define	XPT_DETACHED	10		/* detached from tempsocks list */
 #define XPT_LISTENER	11		/* listening endpoint */
 #define XPT_CACHE_AUTH	12		/* cache auth info */
+#define XPT_SHARE_SOCK	13		/* fore and back channel share socket */
 
 	struct svc_pool		*xpt_pool;	/* current pool iff queued */
 	struct svc_serv		*xpt_server;	/* service for transport */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ea2ff78..8c4d9ad 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -128,7 +128,8 @@ static void svc_xprt_free(struct kref *kref)
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
 	put_net(xprt->xpt_net);
-	xprt->xpt_ops->xpo_free(xprt);
+	if (!test_bit(XPT_SHARE_SOCK, &xprt->xpt_flags))
+		xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
 
-- 
1.6.6

