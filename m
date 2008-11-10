From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 68/85] nfs41: sunrpc: add a struct svc_xprt pointer to struct svc_serv for backchannel use
Date: Mon, 10 Nov 2008 22:30:22 +0200
Message-ID: <1226349022-9500-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60043 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbYKJUa1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:30:27 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This svc_xprt is passed on to the callback service thread to be later used
to processes incoming svc_rqst's

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 1bb51dc..7653dd3 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -90,6 +90,7 @@ struct svc_serv {
 	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
 						 * entries in the svc_cb_list
 						 */
+	struct svc_xprt		*bc_xprt;
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 906b992..b84ae54 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -489,6 +489,10 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
+#if defined(CONFIG_NFS_V4_1)
+	svc_sock_destroy(serv->bc_xprt);
+#endif /* CONFIG_NFS_V4_1 */
+
 	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
-- 
1.6.0.2

