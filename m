Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab1K3Xj0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 18:39:26 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RVtkL-0000Jn-Ci
	for linux-nfs@vger.kernel.org; Wed, 30 Nov 2011 18:39:25 -0500
Date: Wed, 30 Nov 2011 18:39:25 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] svcrpc: destroy server sockets all at once
Message-ID: <20111130233925.GA354@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There's no reason I can see that we need to call sv_shutdown between
closing the two lists of sockets.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svcsock.h |    2 +-
 net/sunrpc/svc.c               |    7 +------
 net/sunrpc/svc_xprt.c          |   11 ++++++++++-
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 85c50b4..c84e974 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -34,7 +34,7 @@ struct svc_sock {
 /*
  * Function prototypes.
  */
-void		svc_close_all(struct list_head *);
+void		svc_close_all(struct svc_serv *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6e03888..60babf0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -528,16 +528,11 @@ svc_destroy(struct svc_serv *serv)
 
 	del_timer_sync(&serv->sv_temptimer);
 
-	svc_close_all(&serv->sv_tempsocks);
+	svc_close_all(serv);
 
 	if (serv->sv_shutdown)
 		serv->sv_shutdown(serv);
 
-	svc_close_all(&serv->sv_permsocks);
-
-	BUG_ON(!list_empty(&serv->sv_permsocks));
-	BUG_ON(!list_empty(&serv->sv_tempsocks));
-
 	cache_clean_deferred(serv);
 
 	if (svc_serv_is_pooled(serv))
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 8046c6d..099ddf9 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -929,7 +929,7 @@ void svc_close_xprt(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_close_xprt);
 
-void svc_close_all(struct list_head *xprt_list)
+static void svc_close_list(struct list_head *xprt_list)
 {
 	struct svc_xprt *xprt;
 	struct svc_xprt *tmp;
@@ -947,6 +947,15 @@ void svc_close_all(struct list_head *xprt_list)
 	}
 }
 
+void svc_close_all(struct svc_serv *serv)
+{
+	svc_close_list(&serv->sv_tempsocks);
+	svc_close_list(&serv->sv_permsocks);
+	BUG_ON(!list_empty(&serv->sv_permsocks));
+	BUG_ON(!list_empty(&serv->sv_tempsocks));
+
+}
+
 /*
  * Handle defer and revisit of requests
  */
-- 
1.7.5.4

