Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:37825 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562Ab2ALGrf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 01:47:35 -0500
Date: Thu, 12 Jan 2012 09:47:22 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] svcrdma: endian bug in send_write_chunks()
Message-ID: <20120112064722.GB2408@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sparse complains because arg_ch->rs_length is declared as network
endian but we're treating it as CPU endian.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 249a835..30fda86 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -409,7 +409,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 		u64 rs_offset;
 
 		arg_ch = &arg_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, arg_ch->rs_length);
+		write_len = min(xfer_len, ntohl(arg_ch->rs_length));
 
 		/* Prepare the response chunk given the length actually
 		 * written */
@@ -481,7 +481,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	     chunk_no++) {
 		u64 rs_offset;
 		ch = &arg_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, ch->rs_length);
+		write_len = min(xfer_len, ntohl(ch->rs_length));
 
 		/* Prepare the reply chunk given the length actually
 		 * written */
