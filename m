Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34682 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753210AbdDKRWc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:22:32 -0400
Subject: [PATCH v3 01/13] xprtrdma: Cancel refresh worker during buffer
 shutdown
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:22:29 -0400
Message-ID: <20170411172229.11300.52129.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
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

