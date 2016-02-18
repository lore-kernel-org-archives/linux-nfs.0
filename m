Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36359 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756473AbcBRRoT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 12:44:19 -0500
Subject: [PATCH v3 04/10] rpcrdma: Add RPCRDMA_HDRLEN_ERR
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 18 Feb 2016 12:44:18 -0500
Message-ID: <20160218174418.12825.31553.stgit@klimt.1015granger.net>
In-Reply-To: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Error headers are shorter than either RDMA_MSG or RDMA_NOMSG.

Since HDRLEN_MIN is already used in several other places that would
be annoying to change, add RPCRDMA_HDRLEN_ERR for the one or two
spots where the shorter length is needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Devesh Sharma <devesh.sharma@broadcom.com>
---
 include/linux/sunrpc/rpc_rdma.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index f33c5a4..8c6d23c 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -102,6 +102,7 @@ struct rpcrdma_msg {
  * Smallest RPC/RDMA header: rm_xid through rm_type, then rm_nochunks
  */
 #define RPCRDMA_HDRLEN_MIN	(sizeof(__be32) * 7)
+#define RPCRDMA_HDRLEN_ERR	(sizeof(__be32) * 5)
 
 enum rpcrdma_errcode {
 	ERR_VERS = 1,

