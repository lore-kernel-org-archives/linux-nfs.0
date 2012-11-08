Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51481 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754404Ab2KHAgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:36:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] svcrpc: demote some printks to a dprintk
Date: Wed,  7 Nov 2012 19:36:11 -0500
Message-Id: <1352334972-28495-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1352334972-28495-1-git-send-email-bfields@redhat.com>
References: <1352334972-28495-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In general I'd rather random bad behavior on the network won't trigger a
printk.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3ee7461..be301e1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1035,7 +1035,7 @@ static void svc_unregister(const struct svc_serv *serv, struct net *net)
 }
 
 /*
- * Printk the given error with the address of the client that caused it.
+ * dprintk the given error with the address of the client that caused it.
  */
 static __printf(2, 3)
 void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
@@ -1049,8 +1049,7 @@ void svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	net_warn_ratelimited("svc: %s: %pV",
-			     svc_print_addr(rqstp, buf, sizeof(buf)), &vaf);
+	dprintk("svc: %s: %pV", svc_print_addr(rqstp, buf, sizeof(buf)), &vaf);
 
 	va_end(args);
 }
-- 
1.7.9.5

