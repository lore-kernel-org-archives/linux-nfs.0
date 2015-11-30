Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33984 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbbK3WOk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 17:14:40 -0500
Subject: [PATCH v2 05/11] xprtrdma: Introduce ro_unmap_sync method
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Nov 2015 17:14:38 -0500
Message-ID: <20151130221438.12235.51061.stgit@manet.1015granger.net>
In-Reply-To: <20151130221349.12235.29565.stgit@manet.1015granger.net>
References: <20151130221349.12235.29565.stgit@manet.1015granger.net>
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
index ca481b2..d2384b5 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -366,6 +366,8 @@ struct rpcrdma_xprt;
 struct rpcrdma_memreg_ops {
 	int		(*ro_map)(struct rpcrdma_xprt *,
 				  struct rpcrdma_mr_seg *, int, bool);
+	void		(*ro_unmap_sync)(struct rpcrdma_xprt *,
+					 struct rpcrdma_req *);
 	int		(*ro_unmap)(struct rpcrdma_xprt *,
 				    struct rpcrdma_mr_seg *);
 	int		(*ro_open)(struct rpcrdma_ia *,

