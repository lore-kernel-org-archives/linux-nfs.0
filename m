Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38656 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbbC3SeY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 14:34:24 -0400
Subject: [PATCH v3 06/15] xprtrdma: Add vector of ops for each memory
 registration strategy
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Mar 2015 14:34:21 -0400
Message-ID: <20150330183421.7856.9623.stgit@manet.1015granger.net>
In-Reply-To: <20150330182615.7856.61170.stgit@manet.1015granger.net>
References: <20150330182615.7856.61170.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of employing switch() statements, let's use the typical
Linux kernel idiom for handling behavioral variation: virtual
functions.

Start by defining a vector of operations for each supported memory
registration mode, and by adding a source file for each mode.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Tested-by: Meghana Cheripady <Meghana.Cheripady@Emulex.Com>
Tested-by: Veeresh U. Kokatnur <veereshuk@chelsio.com>
---
 net/sunrpc/xprtrdma/Makefile       |    3 ++-
 net/sunrpc/xprtrdma/fmr_ops.c      |   22 ++++++++++++++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |   22 ++++++++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |   24 ++++++++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c        |   11 +++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h    |   12 ++++++++++++
 6 files changed, 89 insertions(+), 5 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/fmr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/frwr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/physical_ops.c

diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index da5136f..579f72b 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_SUNRPC_XPRT_RDMA_CLIENT) += xprtrdma.o
 
-xprtrdma-y := transport.o rpc_rdma.o verbs.o
+xprtrdma-y := transport.o rpc_rdma.o verbs.o \
+	fmr_ops.o frwr_ops.o physical_ops.o
 
 obj-$(CONFIG_SUNRPC_XPRT_RDMA_SERVER) += svcrdma.o
 
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
new file mode 100644
index 0000000..ffb7d93
--- /dev/null
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -0,0 +1,22 @@
+/*
+ * Copyright (c) 2015 Oracle.  All rights reserved.
+ * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
+ */
+
+/* Lightweight memory registration using Fast Memory Regions (FMR).
+ * Referred to sometimes as MTHCAFMR mode.
+ *
+ * FMR uses synchronous memory registration and deregistration.
+ * FMR registration is known to be fast, but FMR deregistration
+ * can take tens of usecs to complete.
+ */
+
+#include "xprt_rdma.h"
+
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+# define RPCDBG_FACILITY	RPCDBG_TRANS
+#endif
+
+const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
+	.ro_displayname			= "fmr",
+};
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
new file mode 100644
index 0000000..79173f9
--- /dev/null
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -0,0 +1,22 @@
+/*
+ * Copyright (c) 2015 Oracle.  All rights reserved.
+ * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
+ */
+
+/* Lightweight memory registration using Fast Registration Work
+ * Requests (FRWR). Also referred to sometimes as FRMR mode.
+ *
+ * FRWR features ordered asynchronous registration and deregistration
+ * of arbitrarily sized memory regions. This is the fastest and safest
+ * but most complex memory registration mode.
+ */
+
+#include "xprt_rdma.h"
+
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+# define RPCDBG_FACILITY	RPCDBG_TRANS
+#endif
+
+const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
+	.ro_displayname			= "frwr",
+};
diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
new file mode 100644
index 0000000..b0922ac
--- /dev/null
+++ b/net/sunrpc/xprtrdma/physical_ops.c
@@ -0,0 +1,24 @@
+/*
+ * Copyright (c) 2015 Oracle.  All rights reserved.
+ * Copyright (c) 2003-2007 Network Appliance, Inc. All rights reserved.
+ */
+
+/* No-op chunk preparation. All client memory is pre-registered.
+ * Sometimes referred to as ALLPHYSICAL mode.
+ *
+ * Physical registration is simple because all client memory is
+ * pre-registered and never deregistered. This mode is good for
+ * adapter bring up, but is considered not safe: the server is
+ * trusted not to abuse its access to client memory not involved
+ * in RDMA I/O.
+ */
+
+#include "xprt_rdma.h"
+
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+# define RPCDBG_FACILITY	RPCDBG_TRANS
+#endif
+
+const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
+	.ro_displayname			= "physical",
+};
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 99752b5..c3319e1 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -492,10 +492,10 @@ connected:
 		int ird = attr->max_dest_rd_atomic;
 		int tird = ep->rep_remote_cma.responder_resources;
 
-		pr_info("rpcrdma: connection to %pIS:%u on %s, memreg %d slots %d ird %d%s\n",
+		pr_info("rpcrdma: connection to %pIS:%u on %s, memreg '%s', %d credits, %d responders%s\n",
 			sap, rpc_get_port(sap),
 			ia->ri_id->device->name,
-			ia->ri_memreg_strategy,
+			ia->ri_ops->ro_displayname,
 			xprt->rx_buf.rb_max_requests,
 			ird, ird < 4 && ird < tird / 2 ? " (low!)" : "");
 	} else if (connstate < 0) {
@@ -650,13 +650,16 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	 */
 	switch (memreg) {
 	case RPCRDMA_FRMR:
+		ia->ri_ops = &rpcrdma_frwr_memreg_ops;
 		break;
 	case RPCRDMA_ALLPHYSICAL:
+		ia->ri_ops = &rpcrdma_physical_memreg_ops;
 		mem_priv = IB_ACCESS_LOCAL_WRITE |
 				IB_ACCESS_REMOTE_WRITE |
 				IB_ACCESS_REMOTE_READ;
 		goto register_setup;
 	case RPCRDMA_MTHCAFMR:
+		ia->ri_ops = &rpcrdma_fmr_memreg_ops;
 		if (ia->ri_have_dma_lkey)
 			break;
 		mem_priv = IB_ACCESS_LOCAL_WRITE;
@@ -676,8 +679,8 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		rc = -ENOMEM;
 		goto out3;
 	}
-	dprintk("RPC:       %s: memory registration strategy is %d\n",
-		__func__, memreg);
+	dprintk("RPC:       %s: memory registration strategy is '%s'\n",
+		__func__, ia->ri_ops->ro_displayname);
 
 	/* Else will do memory reg/dereg for each chunk */
 	ia->ri_memreg_strategy = memreg;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c8afd83..ef3cf4a 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -60,6 +60,7 @@
  * Interface Adapter -- one per transport instance
  */
 struct rpcrdma_ia {
+	const struct rpcrdma_memreg_ops	*ri_ops;
 	rwlock_t		ri_qplock;
 	struct rdma_cm_id 	*ri_id;
 	struct ib_pd		*ri_pd;
@@ -331,6 +332,17 @@ struct rpcrdma_stats {
 };
 
 /*
+ * Per-registration mode operations
+ */
+struct rpcrdma_memreg_ops {
+	const char	*ro_displayname;
+};
+
+extern const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops;
+extern const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops;
+extern const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops;
+
+/*
  * RPCRDMA transport -- encapsulates the structures above for
  * integration with RPC.
  *

