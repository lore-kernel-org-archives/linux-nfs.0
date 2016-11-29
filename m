Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32877 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933710AbcK2QE2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 11:04:28 -0500
Subject: [PATCH v3 01/10] svcrdma: Clear xpt_bc_xps in xprt_setup_rdma_bc()
 error exit arm
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 11:04:26 -0500
Message-ID: <20161129160426.4477.13007.stgit@klimt.1015granger.net>
In-Reply-To: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
References: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Logic copied from xs_setup_bc_tcp().

Fixes: 39a9beab5acb ('rpc: share one xps between all backchannels')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 20027f8..6035c5a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -359,6 +359,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 out_fail:
 	xprt_rdma_free_addresses(xprt);
 	args->bc_xprt->xpt_bc_xprt = NULL;
+	args->bc_xprt->xpt_bc_xps = NULL;
 	xprt_put(xprt);
 	xprt_free(xprt);
 	return ERR_PTR(-EINVAL);

