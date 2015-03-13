Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:36053 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbCMVXb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:23:31 -0400
Received: by iegc3 with SMTP id c3so130708572ieg.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:23:30 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id s10sm2031647igr.2.2015.03.13.14.23.29
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:23:29 -0700 (PDT)
Subject: [PATCH v1 14/16] xprtrdma: Remove rpcrdma_ia::ri_memreg_strategy
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:23:28 -0400
Message-ID: <20150313212328.22471.8696.stgit@manet.1015granger.net>
In-Reply-To: <20150313211124.22471.14517.stgit@manet.1015granger.net>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: This field is no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/xprtrdma.h |    3 ++-
 net/sunrpc/xprtrdma/verbs.c     |    3 ---
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 64a0a0a..10bc3cde 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -61,7 +61,8 @@
 
 #define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad (bytes) */
 
-/* memory registration strategies */
+/* Memory registration strategies, by number.
+ * This is part of a kernel / user space API. Do not remove. */
 enum rpcrdma_memreg {
 	RPCRDMA_BOUNCEBUFFERS = 0,
 	RPCRDMA_REGISTER,
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 5b9c104..21b63fe 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -669,9 +669,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	dprintk("RPC:       %s: memory registration strategy is '%s'\n",
 		__func__, ia->ri_ops->ro_displayname);
 
-	/* Else will do memory reg/dereg for each chunk */
-	ia->ri_memreg_strategy = memreg;
-
 	rwlock_init(&ia->ri_qplock);
 	return 0;
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index d5aa5b4..b167e44 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -69,7 +69,6 @@ struct rpcrdma_ia {
 	int			ri_have_dma_lkey;
 	struct completion	ri_done;
 	int			ri_async_rc;
-	enum rpcrdma_memreg	ri_memreg_strategy;
 	unsigned int		ri_max_frmr_depth;
 	struct ib_device_attr	ri_devattr;
 	struct ib_qp_attr	ri_qp_attr;

