Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33213 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752167AbcKIRds (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 12:33:48 -0500
Subject: [PATCH v1 1/7] svcrdma: Clear xpt_bc_xps in xprt_setup_rdma_bc()
 error exit arm
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 12:33:46 -0500
Message-ID: <20161109173346.15735.31869.stgit@klimt.1015granger.net>
In-Reply-To: <20161109165814.15735.47815.stgit@klimt.1015granger.net>
References: <20161109165814.15735.47815.stgit@klimt.1015granger.net>
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

