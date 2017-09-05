Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:38306 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbdIERAX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 13:00:23 -0400
Subject: [PATCH RFC 1/5] xprtrdma: Clean up SGE accounting in
 rpcrdma_prepare_msg_sges()
From: Chuck Lever <chuck.lever@oracle.com>
To: jgunthorpe@obsidianresearch.com, sagi@grimberg.me
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 05 Sep 2017 13:00:20 -0400
Message-ID: <20170905170020.11106.36474.stgit@manet.1015granger.net>
In-Reply-To: <20170905164347.11106.27140.stgit@manet.1015granger.net>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcrdma_prepare_hdr_sges() sets num_sge to one, then
rpcrdma_prepare_msg_sges() sets num_sge again to the count of SGEs
it added, plus one for the header SGE just mapped in
rpcrdma_prepare_hdr_sges().

Let's just add the number we mapped, instead of setting num_sge
again. The behavior should be the same, but the code is slightly
clearer and less likely to break due to unrelated changes.

Similarly, simplify mapped SGE counting by just adding the running
count of SGEs before returning.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 84584ca..7ec4fde 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -607,7 +607,6 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			sge[sge_no].length = len;
 			sge[sge_no].lkey = lkey;
 
-			req->rl_mapped_sges++;
 			ppages++;
 			remaining -= len;
 			page_base = 0;
@@ -633,11 +632,11 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			goto out_mapping_err;
 		sge[sge_no].length = len;
 		sge[sge_no].lkey = lkey;
-		req->rl_mapped_sges++;
 	}
 
 out:
-	req->rl_send_wr.num_sge = sge_no + 1;
+	req->rl_send_wr.num_sge += sge_no;
+	req->rl_mapped_sges += sge_no - 1;
 	return true;
 
 out_mapping_overflow:

