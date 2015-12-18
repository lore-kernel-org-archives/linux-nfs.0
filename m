Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:54258 "EHLO m50-133.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751445AbbLRPfH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2015 10:35:07 -0500
From: Geliang Tang <geliangtang@163.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>
Cc: Geliang Tang <geliangtang@163.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 13/14] sunrpc: use list_for_each_entry_safe
Date: Fri, 18 Dec 2015 23:33:37 +0800
Message-Id: <fddb964a421701bcb303bc2cf3369facbe2bf11b.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use list_for_each_entry_safe() instead of list_for_each_safe() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/sunrpc/svc_xprt.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index a6cbb21..fe4f628 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -904,8 +904,7 @@ out:
 static void svc_age_temp_xprts(unsigned long closure)
 {
 	struct svc_serv *serv = (struct svc_serv *)closure;
-	struct svc_xprt *xprt;
-	struct list_head *le, *next;
+	struct svc_xprt *xprt, *next;
 
 	dprintk("svc_age_temp_xprts\n");
 
@@ -916,9 +915,7 @@ static void svc_age_temp_xprts(unsigned long closure)
 		return;
 	}
 
-	list_for_each_safe(le, next, &serv->sv_tempsocks) {
-		xprt = list_entry(le, struct svc_xprt, xpt_list);
-
+	list_for_each_entry_safe(xprt, next, &serv->sv_tempsocks, xpt_list) {
 		/* First time through, just mark it OLD. Second time
 		 * through, close it. */
 		if (!test_and_set_bit(XPT_OLD, &xprt->xpt_flags))
@@ -926,7 +923,7 @@ static void svc_age_temp_xprts(unsigned long closure)
 		if (atomic_read(&xprt->xpt_ref.refcount) > 1 ||
 		    test_bit(XPT_BUSY, &xprt->xpt_flags))
 			continue;
-		list_del_init(le);
+		list_del_init(&xprt->xpt_list);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 		dprintk("queuing xprt %p for closing\n", xprt);
 
-- 
2.5.0


