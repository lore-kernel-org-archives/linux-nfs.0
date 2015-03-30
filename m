Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35319 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbbC3Sdh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 14:33:37 -0400
Subject: [PATCH v3 01/15] SUNRPC: Introduce missing well-known netids
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Mar 2015 14:33:33 -0400
Message-ID: <20150330183333.7856.19982.stgit@manet.1015granger.net>
In-Reply-To: <20150330182615.7856.61170.stgit@manet.1015granger.net>
References: <20150330182615.7856.61170.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/msg_prot.h |    8 +++++++-
 include/linux/sunrpc/xprtrdma.h |    5 -----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index aadc6a0..8073713 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -142,12 +142,18 @@ typedef __be32	rpc_fraghdr;
 	(RPC_REPHDRSIZE + (2 + RPC_MAX_AUTH_SIZE/4))
 
 /*
- * RFC1833/RFC3530 rpcbind (v3+) well-known netid's.
+ * Well-known netids. See:
+ *
+ *   http://www.iana.org/assignments/rpc-netids/rpc-netids.xhtml
  */
 #define RPCBIND_NETID_UDP	"udp"
 #define RPCBIND_NETID_TCP	"tcp"
+#define RPCBIND_NETID_RDMA	"rdma"
+#define RPCBIND_NETID_SCTP	"sctp"
 #define RPCBIND_NETID_UDP6	"udp6"
 #define RPCBIND_NETID_TCP6	"tcp6"
+#define RPCBIND_NETID_RDMA6	"rdma6"
+#define RPCBIND_NETID_SCTP6	"sctp6"
 #define RPCBIND_NETID_LOCAL	"local"
 
 /*
diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
index 64a0a0a..c984c85 100644
--- a/include/linux/sunrpc/xprtrdma.h
+++ b/include/linux/sunrpc/xprtrdma.h
@@ -41,11 +41,6 @@
 #define _LINUX_SUNRPC_XPRTRDMA_H
 
 /*
- * rpcbind (v3+) RDMA netid.
- */
-#define RPCBIND_NETID_RDMA	"rdma"
-
-/*
  * Constants. Max RPC/NFS header is big enough to account for
  * additional marshaling buffers passed down by Linux client.
  *

