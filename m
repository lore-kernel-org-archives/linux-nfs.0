Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32859 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751747AbeEDTfs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:35:48 -0400
Subject: [PATCH v1 15/19] xprtrdma: Return -ENOBUFS when no pages are
 available
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:35:46 -0400
Message-ID: <20180504193546.31688.50223.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of -EAGAIN in rpcrdma_convert_iovs() is a latent bug: the
transport never calls xprt_write_space() when more pages become
available. -ENOBUFS will trigger the correct "delay briefly and call
again" logic.

Fixes: 7a89f9c626e3 ("xprtrdma: Honor ->send_request API contract")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d676106..1d78579 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -231,7 +231,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 			 */
 			*ppages = alloc_page(GFP_ATOMIC);
 			if (!*ppages)
-				return -EAGAIN;
+				return -ENOBUFS;
 		}
 		seg->mr_page = *ppages;
 		seg->mr_offset = (char *)page_base;

