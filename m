Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35188 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752314AbcKRO7G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 09:59:06 -0500
Subject: [PATCH v2 01/12] xprtrdma: Cap size of callback buffer resources
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 09:59:03 -0500
Message-ID: <20161118145903.10592.46014.stgit@manet.1015granger.net>
In-Reply-To: <20161118145547.10592.66470.stgit@manet.1015granger.net>
References: <20161118145547.10592.66470.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the inline threshold size is set to large values (say, 32KB)
any NFSv4.1 CB request from the server gets a reply with status
NFS4ERR_RESOURCE.

Looks like there are some upper layer assumptions about the maximum
size of a reply (for example, in process_op). Cap the size of the
NFSv4 client's reply resources at a page.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 2c472e1..24fedd4 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -55,7 +55,8 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 	if (IS_ERR(rb))
 		goto out_fail;
 	req->rl_sendbuf = rb;
-	xdr_buf_init(&rqst->rq_snd_buf, rb->rg_base, size);
+	xdr_buf_init(&rqst->rq_snd_buf, rb->rg_base,
+		     min_t(size_t, size, PAGE_SIZE));
 	rpcrdma_set_xprtdata(rqst, req);
 	return 0;
 
@@ -191,6 +192,7 @@ size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *xprt)
 	size_t maxmsg;
 
 	maxmsg = min_t(unsigned int, cdata->inline_rsize, cdata->inline_wsize);
+	maxmsg = min_t(unsigned int, maxmsg, PAGE_SIZE);
 	return maxmsg - RPCRDMA_HDRLEN_MIN;
 }
 

