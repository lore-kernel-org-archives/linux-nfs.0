Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35823 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755614AbaGVOvx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 10:51:53 -0400
Subject: [PATCH v4 06/21] xprtrdma: Don't invalidate FRMRs if registration
 fails
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 10:51:51 -0400
Message-ID: <20140722145151.6010.49734.stgit@manet.1015granger.net>
In-Reply-To: <20140722144459.6010.99389.stgit@manet.1015granger.net>
References: <20140722144459.6010.99389.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If FRMR registration fails, it's likely to transition the QP to the
error state. Or, registration may have failed because the QP is
_already_ in ERROR.

Thus calling rpcrdma_deregister_external() in
rpcrdma_create_chunks() is useless in FRMR mode: the LOCAL_INVs just
get flushed.

It is safe to leave existing registrations: when FRMR registration
is tried again, rpcrdma_register_frmr_external() checks if each FRMR
is already/still VALID, and knocks it down first if it is.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Steve Wise <swise@opengridcomputing.com>
Tested-by: Shirley Ma <shirley.ma@oracle.com>
Tested-by: Devesh Sharma <devesh.sharma@emulex.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 54422f7..6166c98 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -271,9 +271,11 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 	return (unsigned char *)iptr - (unsigned char *)headerp;
 
 out:
-	for (pos = 0; nchunks--;)
-		pos += rpcrdma_deregister_external(
-				&req->rl_segments[pos], r_xprt);
+	if (r_xprt->rx_ia.ri_memreg_strategy != RPCRDMA_FRMR) {
+		for (pos = 0; nchunks--;)
+			pos += rpcrdma_deregister_external(
+					&req->rl_segments[pos], r_xprt);
+	}
 	return n;
 }
 

