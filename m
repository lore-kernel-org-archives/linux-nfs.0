From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 25/30] SUNRPC: Delay, then retry on connection errors.
Date: Wed, 11 Mar 2009 14:41:10 -0400
Message-ID: <20090311184109.5578.90602.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754187AbZCKSpT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:45:19 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIj5jS022182
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:45:17 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Enforce the comment in xs_tcp_connect_worker4/xs_tcp_connect_worker6 that
we should delay, then retry on certain connection errors.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8e58b0b..9f3e615 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1722,20 +1722,19 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
 			xprt, -status, xprt_connected(xprt),
 			sock->sk->sk_state);
 	switch (status) {
+	case -ECONNREFUSED:
+	case -ECONNRESET:
+	case -ENETUNREACH:
+		/* retry with existing socket, after a delay */
 	case 0:
 	case -EINPROGRESS:
 	case -EALREADY:
 		goto out_clear;
-	case -ECONNREFUSED:
-	case -ECONNRESET:
-		/* retry with existing socket, after a delay */
-		break;
-	default:
-		/* get rid of existing socket, and retry */
-		xs_tcp_shutdown(xprt);
-		printk("%s: connect returned unhandled error %d\n",
-				__func__, status);
 	}
+	/* get rid of existing socket, and retry */
+	xs_tcp_shutdown(xprt);
+	printk("%s: connect returned unhandled error %d\n",
+			__func__, status);
 	status = -EAGAIN;
 out:
 	xprt_wake_pending_tasks(xprt, status);
@@ -1783,20 +1782,19 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
 	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);
 	switch (status) {
+	case -ECONNREFUSED:
+	case -ECONNRESET:
+	case -ENETUNREACH:
+		/* retry with existing socket, after a delay */
 	case 0:
 	case -EINPROGRESS:
 	case -EALREADY:
 		goto out_clear;
-	case -ECONNREFUSED:
-	case -ECONNRESET:
-		/* retry with existing socket, after a delay */
-		break;
-	default:
-		/* get rid of existing socket, and retry */
-		xs_tcp_shutdown(xprt);
-		printk("%s: connect returned unhandled error %d\n",
-				__func__, status);
 	}
+	/* get rid of existing socket, and retry */
+	xs_tcp_shutdown(xprt);
+	printk("%s: connect returned unhandled error %d\n",
+			__func__, status);
 	status = -EAGAIN;
 out:
 	xprt_wake_pending_tasks(xprt, status);

