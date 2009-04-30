From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 16/39] nfs41: sunrpc: add a struct svc_xprt pointer to struct svc_serv for backchannel use
Date: Fri,  1 May 2009 02:21:55 +0300
Message-ID: <1241133715-817-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:6126 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756333AbZD3XWE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:22:04 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This svc_xprt is passed on to the callback service thread to be later used
to processes incoming svc_rqst's

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 16043c4..ea80096 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -103,6 +103,7 @@ struct svc_serv {
 	spinlock_t		sv_cb_lock;	/* protects the svc_cb_list */
 	wait_queue_head_t	sv_cb_waitq;	/* sleep here if there are no
 						 * entries in the svc_cb_list */
+	struct svc_xprt		*bc_xprt;
 #endif /* CONFIG_NFS_V4_1 */
 };
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 06b52e4..b35048f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -487,6 +487,10 @@ svc_destroy(struct svc_serv *serv)
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
1.6.2.1

