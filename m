Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32854 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752911AbdDKRYJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:24:09 -0400
Subject: [PATCH v3 13/13] xprtrdma: Remove rpcrdma_buffer::rb_pool
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:24:07 -0400
Message-ID: <20170411172407.11300.76112.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 1e465fd4ff47 ("xprtrdma: Replace send and receive
arrays"), this field is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 1c5de1a..1d66acf 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -391,7 +391,6 @@ struct rpcrdma_buffer {
 	spinlock_t		rb_mwlock;	/* protect rb_mws list */
 	struct list_head	rb_mws;
 	struct list_head	rb_all;
-	char			*rb_pool;
 
 	spinlock_t		rb_lock;	/* protect buf lists */
 	int			rb_send_count, rb_recv_count;

