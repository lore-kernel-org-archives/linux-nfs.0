Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:42793 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681AbaGVUAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 16:00:33 -0400
Received: by mail-ig0-f180.google.com with SMTP id l13so636732iga.13
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 13:00:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] svcrdma: Increase credit limit to 32
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 16:00:31 -0400
Message-ID: <20140722200031.6011.28421.stgit@klimt.1015granger.net>
In-Reply-To: <20140722195840.6011.87861.stgit@klimt.1015granger.net>
References: <20140722195840.6011.87861.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 5cf99a0..975da75 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -174,8 +174,7 @@ struct svcxprt_rdma {
  * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
 #define RPCRDMA_ORD             (64/4)
 #define RPCRDMA_SQ_DEPTH_MULT   8
-#define RPCRDMA_MAX_THREADS     16
-#define RPCRDMA_MAX_REQUESTS    16
+#define RPCRDMA_MAX_REQUESTS    32
 #define RPCRDMA_MAX_REQ_SIZE    4096
 
 /* svc_rdma_marshal.c */

