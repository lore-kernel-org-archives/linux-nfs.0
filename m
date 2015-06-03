Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38116 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755633AbbFCOoQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 10:44:16 -0400
Received: by wibdt2 with SMTP id dt2so15799036wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 Jun 2015 07:44:15 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>,
        Jerome Marchand <jmarchan@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 4/5] sunrpc: lock xprt before trying to set memalloc on the sockets
Date: Wed,  3 Jun 2015 10:43:51 -0400
Message-Id: <1433342632-16173-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
References: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that we could race with a call to xs_reset_transport, in
which case the xprt->inet pointer could be zeroed out while we're
accessing it. Lock the xprt before we try to set memalloc on it.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/xprtsock.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 359446442112..16aa5dad41b2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1964,11 +1964,22 @@ static void xs_local_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 }
 
 #ifdef CONFIG_SUNRPC_SWAP
+/*
+ * Note that this should be called with XPRT_LOCKED held (or when we otherwise
+ * know that we have exclusive access to the socket), to guard against
+ * races with xs_reset_transport.
+ */
 static void xs_set_memalloc(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
 			xprt);
 
+	/*
+	 * If there's no sock, then we have nothing to set. The
+	 * reconnecting process will get it for us.
+	 */
+	if (!transport->inet)
+		return;
 	if (atomic_read(&xprt->swapper))
 		sk_set_memalloc(transport->inet);
 }
@@ -1983,11 +1994,15 @@ static void xs_set_memalloc(struct rpc_xprt *xprt)
 int
 xs_swapper_enable(struct rpc_xprt *xprt)
 {
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
-			xprt);
+	struct sock_xprt *xs = container_of(xprt, struct sock_xprt, xprt);
 
-	if (atomic_inc_return(&xprt->swapper) == 1)
-		sk_set_memalloc(transport->inet);
+	if (atomic_inc_return(&xprt->swapper) != 1)
+		return 0;
+	if (wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_KILLABLE))
+		return -ERESTARTSYS;
+	if (xs->inet)
+		sk_set_memalloc(xs->inet);
+	xprt_release_xprt(xprt, NULL);
 	return 0;
 }
 
@@ -2001,11 +2016,15 @@ xs_swapper_enable(struct rpc_xprt *xprt)
 void
 xs_swapper_disable(struct rpc_xprt *xprt)
 {
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt,
-			xprt);
+	struct sock_xprt *xs = container_of(xprt, struct sock_xprt, xprt);
 
-	if (atomic_dec_and_test(&xprt->swapper))
-		sk_clear_memalloc(transport->inet);
+	if (!atomic_dec_and_test(&xprt->swapper))
+		return;
+	if (wait_on_bit_lock(&xprt->state, XPRT_LOCKED, TASK_KILLABLE))
+		return;
+	if (xs->inet)
+		sk_clear_memalloc(xs->inet);
+	xprt_release_xprt(xprt, NULL);
 }
 #else
 static void xs_set_memalloc(struct rpc_xprt *xprt)
-- 
2.4.2

