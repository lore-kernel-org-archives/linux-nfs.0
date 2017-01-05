Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57184 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753313AbdAEVfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jan 2017 16:35:11 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org, jlayton@poochiereds.net
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] sunrpc: don't call sleeping functions from the notifier block callbacks
Date: Thu,  5 Jan 2017 16:34:51 -0500
Message-Id: <1483652091-25508-4-git-send-email-smayhew@redhat.com>
In-Reply-To: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
References: <1483652091-25508-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The inet6addr_chain is an atomic notifier chain, so we can't call
anything that might sleep (like lock_sock)... instead of closing the
socket from svc_age_temp_xprts_now (which is called by the notifier
function), just have the rpc service threads do it instead.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h |  1 +
 net/sunrpc/svc_xprt.c           | 10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index e5d1934..7440290 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -66,6 +66,7 @@ struct svc_xprt {
 #define XPT_LISTENER	10		/* listening endpoint */
 #define XPT_CACHE_AUTH	11		/* cache auth info */
 #define XPT_LOCAL	12		/* connection from loopback interface */
+#define XPT_KILL_TEMP   13		/* call xpo_kill_temp_xprt before closing */
 
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 3bc1d61..9c9db55 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -799,6 +799,8 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 
 	if (test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		dprintk("svc_recv: found XPT_CLOSE\n");
+		if (test_and_clear_bit(XPT_KILL_TEMP, &xprt->xpt_flags))
+			xprt->xpt_ops->xpo_kill_temp_xprt(xprt);
 		svc_delete_xprt(xprt);
 		/* Leave XPT_BUSY set on the dead xprt: */
 		goto out;
@@ -1020,9 +1022,11 @@ void svc_age_temp_xprts_now(struct svc_serv *serv, struct sockaddr *server_addr)
 		le = to_be_closed.next;
 		list_del_init(le);
 		xprt = list_entry(le, struct svc_xprt, xpt_list);
-		dprintk("svc_age_temp_xprts_now: closing %p\n", xprt);
-		xprt->xpt_ops->xpo_kill_temp_xprt(xprt);
-		svc_close_xprt(xprt);
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		set_bit(XPT_KILL_TEMP, &xprt->xpt_flags);
+		dprintk("svc_age_temp_xprts_now: queuing xprt %p for closing\n",
+				xprt);
+		svc_xprt_enqueue(xprt);
 	}
 }
 EXPORT_SYMBOL_GPL(svc_age_temp_xprts_now);
-- 
2.7.4

