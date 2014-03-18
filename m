Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:54039 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbaCRXp6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Mar 2014 19:45:58 -0400
Received: by mail-qg0-f49.google.com with SMTP id z60so23307751qgd.8
        for <linux-nfs@vger.kernel.org>; Tue, 18 Mar 2014 16:45:57 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH] xprtrdma: add separate Kconfig options for NFSoRDMA client and server support
Date: Tue, 18 Mar 2014 19:45:47 -0400
Message-Id: <1395186347-11969-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are two entirely separate modules under xprtrdma/ and there's no
reason that enabling one should automatically enable the other. Add
config options for each one so they can be enabled/disabled separately.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/Kconfig           | 39 ++++++++++++++++++++++++++-------------
 net/sunrpc/Makefile          |  3 ++-
 net/sunrpc/xprtrdma/Makefile |  4 ++--
 3 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 241b54f30204..0754d0f466d2 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -9,19 +9,6 @@ config SUNRPC_BACKCHANNEL
 	bool
 	depends on SUNRPC
 
-config SUNRPC_XPRT_RDMA
-	tristate
-	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
-	default SUNRPC && INFINIBAND
-	help
-	  This option allows the NFS client and server to support
-	  an RDMA-enabled transport.
-
-	  To compile RPC client RDMA transport support as a module,
-	  choose M here: the module will be called xprtrdma.
-
-	  If unsure, say N.
-
 config SUNRPC_SWAP
 	bool
 	depends on SUNRPC
@@ -57,3 +44,29 @@ config SUNRPC_DEBUG
 	  but makes troubleshooting NFS issues significantly harder.
 
 	  If unsure, say Y.
+
+config SUNRPC_XPRT_RDMA_CLIENT
+	tristate "RPC over RDMA Client Support"
+	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
+	default SUNRPC && INFINIBAND
+	help
+	  This option allows the NFS client to support an RDMA-enabled
+	  transport.
+
+	  To compile RPC client RDMA transport support as a module,
+	  choose M here: the module will be called xprtrdma.
+
+	  If unsure, say N.
+
+config SUNRPC_XPRT_RDMA_SERVER
+	tristate "RPC over RDMA Server Support"
+	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
+	default SUNRPC && INFINIBAND
+	help
+	  This option allows the NFS server to support an RDMA-enabled
+	  transport.
+
+	  To compile RPC server RDMA transport support as a module,
+	  choose M here: the module will be called svcrdma.
+
+	  If unsure, say N.
diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
index 8209a0411bca..e5a7a1cac8f3 100644
--- a/net/sunrpc/Makefile
+++ b/net/sunrpc/Makefile
@@ -5,7 +5,8 @@
 
 obj-$(CONFIG_SUNRPC) += sunrpc.o
 obj-$(CONFIG_SUNRPC_GSS) += auth_gss/
-obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
+
+obj-y += xprtrdma/
 
 sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
 	    auth.o auth_null.o auth_unix.o auth_generic.o \
diff --git a/net/sunrpc/xprtrdma/Makefile b/net/sunrpc/xprtrdma/Makefile
index 5a8f268bdd30..da5136fd5694 100644
--- a/net/sunrpc/xprtrdma/Makefile
+++ b/net/sunrpc/xprtrdma/Makefile
@@ -1,8 +1,8 @@
-obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma.o
+obj-$(CONFIG_SUNRPC_XPRT_RDMA_CLIENT) += xprtrdma.o
 
 xprtrdma-y := transport.o rpc_rdma.o verbs.o
 
-obj-$(CONFIG_SUNRPC_XPRT_RDMA) += svcrdma.o
+obj-$(CONFIG_SUNRPC_XPRT_RDMA_SERVER) += svcrdma.o
 
 svcrdma-y := svc_rdma.o svc_rdma_transport.o \
 	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
-- 
1.8.5.3

