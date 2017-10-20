Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:46491 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdJTOrl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 10:47:41 -0400
Subject: [PATCH 1/9] xprtrdma: Clean up SGE accounting in
 rpcrdma_prepare_msg_sges()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 20 Oct 2017 10:47:39 -0400
Message-ID: <20171020144739.14869.76628.stgit@manet.1015granger.net>
In-Reply-To: <20171020143635.14869.15714.stgit@manet.1015granger.net>
References: <20171020143635.14869.15714.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. rpcrdma_prepare_hdr_sge() sets num_sge to one, then
rpcrdma_prepare_msg_sges() sets num_sge again to the count of SGEs
it added, plus one for the header SGE just mapped in
rpcrdma_prepare_hdr_sge(). This is confusing, and nails in an
assumption about when these functions are called.

Instead, maintain a running count that both functions can update
with just the number of SGEs they have added to the SGE array.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b8818c09..3c92558 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -637,7 +637,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	}
 
 out:
-	req->rl_send_wr.num_sge = sge_no + 1;
+	req->rl_send_wr.num_sge += sge_no;
 	return true;
 
 out_mapping_overflow:

