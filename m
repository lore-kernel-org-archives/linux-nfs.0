Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:41561 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754571AbdLOB4f (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:56:35 -0500
Subject: [PATCH v1 05/16] xprtrdma: Remove ri_reminv_expected
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:56:34 -0500
Message-ID: <20171215015634.13776.96134.stgit@manet.1015granger.net>
In-Reply-To: <20171215015403.13776.46706.stgit@manet.1015granger.net>
References: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Commit b5f0afbea4f2 ("xprtrdma: Per-connection pad optimization")
should have removed this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    2 --
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 2 files changed, 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1cf1eb4..4a9b6f8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -192,7 +192,6 @@
 	unsigned int rsize, wsize;
 
 	/* Default settings for RPC-over-RDMA Version One */
-	r_xprt->rx_ia.ri_reminv_expected = false;
 	r_xprt->rx_ia.ri_implicit_roundup = xprt_rdma_pad_optimize;
 	rsize = RPCRDMA_V1_DEF_INLINE_SIZE;
 	wsize = RPCRDMA_V1_DEF_INLINE_SIZE;
@@ -200,7 +199,6 @@
 	if (pmsg &&
 	    pmsg->cp_magic == rpcrdma_cmp_magic &&
 	    pmsg->cp_version == RPCRDMA_CMP_VERSION) {
-		r_xprt->rx_ia.ri_reminv_expected = true;
 		r_xprt->rx_ia.ri_implicit_roundup = true;
 		rsize = rpcrdma_decode_buffer_size(pmsg->cp_send_size);
 		wsize = rpcrdma_decode_buffer_size(pmsg->cp_recv_size);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index e787dda..80ea3db 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -77,7 +77,6 @@ struct rpcrdma_ia {
 	unsigned int		ri_max_inline_write;
 	unsigned int		ri_max_inline_read;
 	unsigned int		ri_max_send_sges;
-	bool			ri_reminv_expected;
 	bool			ri_implicit_roundup;
 	enum ib_mr_type		ri_mrtype;
 	unsigned long		ri_flags;

