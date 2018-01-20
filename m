Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:42969 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755643AbeATQQh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Jan 2018 11:16:37 -0500
Subject: [PATCH v3 2/2] rpcrdma: infrastructure for static trace points in
 rpcrdma.ko
From: Chuck Lever <chuck.lever@oracle.com>
To: jgg@ziepe.ca, dledford@redhat.com, anna.schumaker@netapp.com,
        leon@kernel.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 20 Jan 2018 11:16:34 -0500
Message-ID: <20180120161634.6488.26218.stgit@manet.1015granger.net>
In-Reply-To: <20180120161440.6488.4311.stgit@manet.1015granger.net>
References: <20180120161440.6488.4311.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |   16 ++++++++++++++++
 net/sunrpc/xprtrdma/module.c    |   12 +++++++-----
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
 3 files changed, 25 insertions(+), 5 deletions(-)
 create mode 100644 include/trace/events/rpcrdma.h

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
new file mode 100644
index 0000000..8536d90
--- /dev/null
+++ b/include/trace/events/rpcrdma.h
@@ -0,0 +1,16 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Copyright (c) 2017 Oracle.  All rights reserved.
+ */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM rpcrdma
+
+#if !defined(_TRACE_RPCRDMA_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_RPCRDMA_H
+
+#include <linux/tracepoint.h>
+#include <trace/events/rdma.h>
+
+#endif /* _TRACE_RPCRDMA_H */
+
+#include <trace/define_trace.h>
diff --git a/net/sunrpc/xprtrdma/module.c b/net/sunrpc/xprtrdma/module.c
index 560712b..a762d19 100644
--- a/net/sunrpc/xprtrdma/module.c
+++ b/net/sunrpc/xprtrdma/module.c
@@ -1,18 +1,20 @@
 /*
- * Copyright (c) 2015 Oracle.  All rights reserved.
+ * Copyright (c) 2015, 2017 Oracle.  All rights reserved.
  */
 
 /* rpcrdma.ko module initialization
  */
 
+#include <linux/types.h>
+#include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/sunrpc/svc_rdma.h>
-#include "xprt_rdma.h"
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-# define RPCDBG_FACILITY	RPCDBG_TRANS
-#endif
+#include <asm/swab.h>
+
+#define CREATE_TRACE_POINTS
+#include "xprt_rdma.h"
 
 MODULE_AUTHOR("Open Grid Computing and Network Appliance, Inc.");
 MODULE_DESCRIPTION("RPC/RDMA Transport");
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 28ae1fb..a1ca1b6 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -675,3 +675,5 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 extern struct xprt_class xprt_rdma_bc;
 
 #endif				/* _LINUX_SUNRPC_XPRT_RDMA_H */
+
+#include <trace/events/rpcrdma.h>

