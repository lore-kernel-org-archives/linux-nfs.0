Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35515 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbbGIUpu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:45:50 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 5/5] svcrdma: Boost NFS READ/WRITE payload size maximum
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Thu, 09 Jul 2015 16:45:47 -0400
Message-ID: <20150709204546.8481.65857.stgit@klimt.1015granger.net>
In-Reply-To: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
References: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Increased to 1 megabyte.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_rdma.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 13af61b..1bca6dd 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -172,7 +172,7 @@ struct svcxprt_rdma {
 #define RDMAXPRT_SQ_PENDING	2
 #define RDMAXPRT_CONN_PENDING	3
 
-#define RPCRDMA_MAX_SVC_SEGS	(64)	/* server max scatter/gather */
+#define RPCRDMA_MAX_SVC_SEGS	(256)	/* server max scatter/gather */
 #if RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_SVC_SEGS << PAGE_SHIFT)
 #define RPCRDMA_MAXPAYLOAD	RPCSVC_MAXPAYLOAD
 #else

