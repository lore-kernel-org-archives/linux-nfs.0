Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45714 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030329AbbKEIkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 03:40:06 -0500
Date: Thu, 5 Nov 2015 11:39:52 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Sagi Grimberg <sagig@mellanox.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch 2/2] xprtrdma: checking for NULL instead of IS_ERR()
Message-ID: <20151105083952.GB19405@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpcrdma_create_req() function returns error pointers or success.  It
never returns NULL.

Fixes: f531a5dbc451 ('xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 2dcb44f..97554ca 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -42,8 +42,8 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
 	size_t size;
 
 	req = rpcrdma_create_req(r_xprt);
-	if (!req)
-		return -ENOMEM;
+	if (IS_ERR(req))
+		return PTR_ERR(req);
 	req->rl_backchannel = true;
 
 	size = RPCRDMA_INLINE_WRITE_THRESHOLD(rqst);
