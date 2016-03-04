Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35247 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760216AbcCDQ2N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 11:28:13 -0500
Subject: [PATCH v3 06/11] rpcrdma: Add RPCRDMA_HDRLEN_ERR
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 Mar 2016 11:28:09 -0500
Message-ID: <20160304162809.13590.25065.stgit@oracle120-ib.cthon.org>
In-Reply-To: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
References: <20160304162447.13590.9524.stgit@oracle120-ib.cthon.org>
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

