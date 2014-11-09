Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:39850 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbaKIBOX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:14:23 -0500
Subject: [PATCH v2 02/10] xprtrdma: Cap req_cqinit
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:14:20 -0500
Message-ID: <20141109011420.8806.1849.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent work made FRMR registration and invalidation completions
unsignaled. This greatly reduces the adapter interrupt rate.

Every so often, however, a posted send Work Request is allowed to
signal. Otherwise, the provider's Work Queue will wrap and the
workload will hang.

The number of Work Requests that are allowed to remain unsignaled is
determined by the value of req_cqinit. Currently, this is set to the
size of the send Work Queue divided by two, minus 1.

For FRMR, the send Work Queue is the maximum number of concurrent
RPCs (currently 32) times the maximum number of Work Requests an
RPC might use (currently 7, though some adapters may need more).

For mlx4, this is 224 entries. This leaves completion signaling
disabled for 111 send Work Requests.

Some providers hold back dispatching Work Requests until a CQE is
generated.  If completions are disabled, then no CQEs are generated
for quite some time, and that can stall the Work Queue.

I've seen this occur running xfstests generic/113 over NFSv4, where
eventually, posting a FAST_REG_MR Work Request fails with -ENOMEM
because the Work Queue has overflowed. The connection is dropped
and re-established.

Cap the rep_cqinit setting so completions are not left turned off
for too long.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=269
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    4 +++-
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 ++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6ea2942..af45cf3 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -733,7 +733,9 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	/* set trigger for requesting send completion */
 	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 - 1;
-	if (ep->rep_cqinit <= 2)
+	if (ep->rep_cqinit > RPCRDMA_MAX_UNSIGNALED_SENDS)
+		ep->rep_cqinit = RPCRDMA_MAX_UNSIGNALED_SENDS;
+	else if (ep->rep_cqinit <= 2)
 		ep->rep_cqinit = 0;
 	INIT_CQCOUNT(ep);
 	ep->rep_ia = ia;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index ac7fc9a..b799041 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -97,6 +97,12 @@ struct rpcrdma_ep {
 	struct ib_wc		rep_recv_wcs[RPCRDMA_POLLSIZE];
 };
 
+/*
+ * Force a signaled SEND Work Request every so often,
+ * in case the provider needs to do some housekeeping.
+ */
+#define RPCRDMA_MAX_UNSIGNALED_SENDS	(32)
+
 #define INIT_CQCOUNT(ep) atomic_set(&(ep)->rep_cqcount, (ep)->rep_cqinit)
 #define DECR_CQCOUNT(ep) atomic_sub_return(1, &(ep)->rep_cqcount)
 

