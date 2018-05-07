Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34486 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752601AbeEGT1I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:27:08 -0400
Subject: [PATCH v1 03/19] xprtrdma: Prepare RPC/RDMA includes for
 server-side trace points
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:27:05 -0400
Message-ID: <20180507192705.4608.26589.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move #include <trace/events/rpcrdma.h> into source files,
similar to how it is done with trace/events/sunrpc.h.

Server-side trace points will be part of the rpcrdma subsystem,
just like the client-side trace points.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    1 +
 net/sunrpc/xprtrdma/fmr_ops.c     |    1 +
 net/sunrpc/xprtrdma/frwr_ops.c    |    1 +
 net/sunrpc/xprtrdma/module.c      |    4 +++-
 net/sunrpc/xprtrdma/rpc_rdma.c    |    5 +++--
 net/sunrpc/xprtrdma/svc_rdma.c    |    2 +-
 net/sunrpc/xprtrdma/transport.c   |    1 +
 net/sunrpc/xprtrdma/verbs.c       |    1 +
 net/sunrpc/xprtrdma/xprt_rdma.h   |    2 --
 9 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 47ebac9..05c69ac 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -11,6 +11,7 @@
 #include <linux/sunrpc/svc_xprt.h>
 
 #include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_TRANS
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 5cc68a8..08de7da 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -21,6 +21,7 @@
  */
 
 #include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_TRANS
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index c5743a0..f8312e3 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -73,6 +73,7 @@
 #include <linux/sunrpc/rpc_rdma.h>
 
 #include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_TRANS
diff --git a/net/sunrpc/xprtrdma/module.c b/net/sunrpc/xprtrdma/module.c
index a762d19..d95ac07 100644
--- a/net/sunrpc/xprtrdma/module.c
+++ b/net/sunrpc/xprtrdma/module.c
@@ -13,9 +13,11 @@
 
 #include <asm/swab.h>
 
-#define CREATE_TRACE_POINTS
 #include "xprt_rdma.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/rpcrdma.h>
+
 MODULE_AUTHOR("Open Grid Computing and Network Appliance, Inc.");
 MODULE_DESCRIPTION("RPC/RDMA Transport");
 MODULE_LICENSE("Dual BSD/GPL");
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e8adad3..f358d1e 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -46,10 +46,11 @@
  * to the Linux RPC framework lives.
  */
 
-#include "xprt_rdma.h"
-
 #include <linux/highmem.h>
 
+#include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
+
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_TRANS
 #endif
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index a490532..357ba90 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
 /*
+ * Copyright (c) 2015-2018 Oracle.  All rights reserved.
  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
@@ -47,7 +48,6 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/svc_rdma.h>
-#include "xprt_rdma.h"
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index cc1aad3..3d1b277 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -54,6 +54,7 @@
 #include <linux/sunrpc/addr.h>
 
 #include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define RPCDBG_FACILITY	RPCDBG_TRANS
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fe5eaca..a143c59 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -59,6 +59,7 @@
 #include <rdma/ib_cm.h>
 
 #include "xprt_rdma.h"
+#include <trace/events/rpcrdma.h>
 
 /*
  * Globals/Macros
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3d3b423..3f856c7 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -675,5 +675,3 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 extern struct xprt_class xprt_rdma_bc;
 
 #endif				/* _LINUX_SUNRPC_XPRT_RDMA_H */
-
-#include <trace/events/rpcrdma.h>

