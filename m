Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33981 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752845AbdC0OGL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 10:06:11 -0400
Subject: [PATCH v2 01/13] xprtrdma: Cancel refresh worker during buffer
 shutdown
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 10:05:43 -0400
Message-ID: <20170327140543.20813.66981.stgit@manet.1015granger.net>
In-Reply-To: <20170327134847.20813.52412.stgit@manet.1015granger.net>
References: <20170327134847.20813.52412.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trying to create MRs while the transport is being torn down can
cause a crash.

Fixes: e2ac236c0b65 ("xprtrdma: Allocate MRs on demand")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3b332b3..2e4fc1e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1037,6 +1037,7 @@ struct rpcrdma_rep *
 rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
 {
 	cancel_delayed_work_sync(&buf->rb_recovery_worker);
+	cancel_delayed_work_sync(&buf->rb_refresh_worker);
 
 	while (!list_empty(&buf->rb_recv_bufs)) {
 		struct rpcrdma_rep *rep;

