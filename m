Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:33844 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbaKQWDD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 17:03:03 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so18723475qcw.34
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 14:03:02 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: eliminate the XPT_DETACHED flag
Date: Mon, 17 Nov 2014 17:02:57 -0500
Message-Id: <1416261777-25142-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All it does is indicate whether a xprt has already been deleted from
a list or not, which is unnecessary since we use list_del_init and it's
always set and checked under the sv_lock anyway.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/svc_xprt.h | 7 +++----
 net/sunrpc/svc_xprt.c           | 4 +---
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index ce6e4182a5b2..79f6f8f3dc0a 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -63,10 +63,9 @@ struct svc_xprt {
 #define	XPT_CHNGBUF	7		/* need to change snd/rcv buf sizes */
 #define	XPT_DEFERRED	8		/* deferred request pending */
 #define	XPT_OLD		9		/* used for xprt aging mark+sweep */
-#define	XPT_DETACHED	10		/* detached from tempsocks list */
-#define XPT_LISTENER	11		/* listening endpoint */
-#define XPT_CACHE_AUTH	12		/* cache auth info */
-#define XPT_LOCAL	13		/* connection from loopback interface */
+#define XPT_LISTENER	10		/* listening endpoint */
+#define XPT_CACHE_AUTH	11		/* cache auth info */
+#define XPT_LOCAL	12		/* connection from loopback interface */
 
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bbb3b044b877..5c71ccb9659d 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -895,7 +895,6 @@ static void svc_age_temp_xprts(unsigned long closure)
 			continue;
 		list_del_init(le);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
-		set_bit(XPT_DETACHED, &xprt->xpt_flags);
 		dprintk("queuing xprt %p for closing\n", xprt);
 
 		/* a thread will dequeue and close it soon */
@@ -935,8 +934,7 @@ static void svc_delete_xprt(struct svc_xprt *xprt)
 	xprt->xpt_ops->xpo_detach(xprt);
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
-		list_del_init(&xprt->xpt_list);
+	list_del_init(&xprt->xpt_list);
 	WARN_ON_ONCE(!list_empty(&xprt->xpt_ready));
 	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 		serv->sv_tmpcnt--;
-- 
2.1.0

