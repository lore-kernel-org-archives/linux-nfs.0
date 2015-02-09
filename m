Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:57720 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933169AbbBIRTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:19:03 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so17902883igk.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:19:02 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 12/14] SUNRPC: Remove the redundant XPRT_CONNECTION_CLOSE flag
Date: Mon,  9 Feb 2015 12:18:42 -0500
Message-Id: <1423502324-25981-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-12-git-send-email-trond.myklebust@primarydata.com>
References: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-2-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-3-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-4-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-5-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-6-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-7-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-8-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-9-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-10-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-11-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/xprt.h | 1 -
 net/sunrpc/xprt.c           | 1 -
 net/sunrpc/xprtsock.c       | 1 -
 3 files changed, 3 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index ae39d478a272..8b93ef53df3c 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -360,7 +360,6 @@ void			xprt_unlock_connect(struct rpc_xprt *, void *);
 #define XPRT_BOUND		(4)
 #define XPRT_BINDING		(5)
 #define XPRT_CLOSING		(6)
-#define XPRT_CONNECTION_CLOSE	(8)
 #define XPRT_CONGESTED		(9)
 
 static inline void xprt_set_connected(struct rpc_xprt *xprt)
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ff3574df8344..e3015aede0d9 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -683,7 +683,6 @@ xprt_init_autodisconnect(unsigned long data)
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		goto out_abort;
 	spin_unlock(&xprt->transport_lock);
-	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
 	queue_work(rpciod_workqueue, &xprt->task_cleanup);
 	return;
 out_abort:
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 0279e8ffb14a..c72b13e2bdf5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -804,7 +804,6 @@ static void xs_error_report(struct sock *sk)
 static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
 {
 	smp_mb__before_atomic();
-	clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_atomic();
-- 
2.1.0

