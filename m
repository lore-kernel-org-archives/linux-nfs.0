Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36444 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338AbbLNVSV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:18:21 -0500
Subject: [PATCH v3 05/11] xprtrdma: Introduce ro_unmap_sync method
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:18:19 -0500
Message-ID: <20151214211819.16295.53893.stgit@manet.1015granger.net>
In-Reply-To: <20151214211317.16295.70115.stgit@manet.1015granger.net>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the current xprtrdma implementation, some memreg strategies
implement ro_unmap synchronously (the MR is knocked down before the
method returns) and some asynchonously (the MR will be knocked down
and returned to the pool in the background).

To guarantee the MR is truly invalid before the RPC consumer is
allowed to resume execution, we need an unmap method that is
always synchronous, invoked from the RPC/RDMA reply handler.

The new method unmaps all MRs for an RPC. The existing ro_unmap
method unmaps only one MR at a time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index e60d817..d9f2f65 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -365,6 +365,8 @@ struct rpcrdma_xprt;
 struct rpcrdma_memreg_ops {
 	int		(*ro_map)(struct rpcrdma_xprt *,
 				  struct rpcrdma_mr_seg *, int, bool);
+	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
+					 struct rpcrdma_req *);
 	int		(*ro_unmap)(struct rpcrdma_xprt *,
 				    struct rpcrdma_mr_seg *);
 	int		(*ro_open)(struct rpcrdma_ia *,

