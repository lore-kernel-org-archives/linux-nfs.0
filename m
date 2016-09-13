Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35932 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758881AbcIMOxJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2016 10:53:09 -0400
Subject: [PATCH v3 4/6] rpcrdma: RDMA/CM private message data structure
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 13 Sep 2016 10:53:07 -0400
Message-ID: <20160913145307.5733.62842.stgit@klimt.1015granger.net>
In-Reply-To: <20160913144246.5733.66229.stgit@klimt.1015granger.net>
References: <20160913144246.5733.66229.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce data structure used by both client and server to exchange
implementation details during RDMA/CM connection establishment.

This is an experimental out-of-band exchange between Linux
RPC-over-RDMA Version One implementations, replacing the deprecated
CCP (see RFC 5666bis). The purpose of this extension is to enable
prototyping of features that might be introduced in a subsequent
version of RPC-over-RDMA.

Suggested by Christoph Hellwig and Devesh Sharma.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 include/linux/sunrpc/rpc_rdma.h |   35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/include/linux/sunrpc/rpc_rdma.h b/include/linux/sunrpc/rpc_rdma.h
index 3b1ff38..a7da6bf 100644
--- a/include/linux/sunrpc/rpc_rdma.h
+++ b/include/linux/sunrpc/rpc_rdma.h
@@ -41,6 +41,7 @@
 #define _LINUX_SUNRPC_RPC_RDMA_H
 
 #include <linux/types.h>
+#include <linux/bitops.h>
 
 #define RPCRDMA_VERSION		1
 #define rpcrdma_version		cpu_to_be32(RPCRDMA_VERSION)
@@ -129,4 +130,38 @@ enum rpcrdma_proc {
 #define rdma_done	cpu_to_be32(RDMA_DONE)
 #define rdma_error	cpu_to_be32(RDMA_ERROR)
 
+/*
+ * Private extension to RPC-over-RDMA Version One.
+ * Message passed during RDMA-CM connection set-up.
+ *
+ * Add new fields at the end, and don't permute existing
+ * fields.
+ */
+struct rpcrdma_connect_private {
+	__be32			cp_magic;
+	u8			cp_version;
+	u8			cp_flags;
+	u8			cp_send_size;
+	u8			cp_recv_size;
+} __packed;
+
+#define rpcrdma_cmp_magic	__cpu_to_be32(0xf6ab0e18)
+
+enum {
+	RPCRDMA_CMP_VERSION		= 1,
+	RPCRDMA_CMP_F_SND_W_INV_OK	= BIT(0),
+};
+
+static inline u8
+rpcrdma_encode_buffer_size(unsigned int size)
+{
+	return (size >> 10) - 1;
+}
+
+static inline unsigned int
+rpcrdma_decode_buffer_size(u8 val)
+{
+	return ((unsigned int)val + 1) << 10;
+}
+
 #endif				/* _LINUX_SUNRPC_RPC_RDMA_H */

