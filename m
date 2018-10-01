Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f65.google.com ([209.85.166.65]:33131 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726362AbeJBAzP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 20:55:15 -0400
Subject: [PATCH v1 4/4] svcrdma: Increase the default connection credit limit
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:16:11 -0400
Message-ID: <20181001181611.2305.48362.stgit@klimt.1015granger.net>
In-Reply-To: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reduce queuing on clients by allowing more credits by default.

64 is the default NFSv4.1 slot table size on Linux clients. This
size prevents the credit limit from putting RPC requests to sleep
again after they have already slept waiting for a session slot.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_rdma.h |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index fd78f78..e6e2691 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -113,13 +113,14 @@ struct svcxprt_rdma {
 /* sc_flags */
 #define RDMAXPRT_CONN_PENDING	3
 
-#define RPCRDMA_LISTEN_BACKLOG  10
-#define RPCRDMA_MAX_REQUESTS    32
-
-/* Typical ULP usage of BC requests is NFSv4.1 backchannel. Our
- * current NFSv4.1 implementation supports one backchannel slot.
+/*
+ * Default connection parameters
  */
-#define RPCRDMA_MAX_BC_REQUESTS	2
+enum {
+	RPCRDMA_LISTEN_BACKLOG	= 10,
+	RPCRDMA_MAX_REQUESTS	= 64,
+	RPCRDMA_MAX_BC_REQUESTS	= 2,
+};
 
 #define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
 
