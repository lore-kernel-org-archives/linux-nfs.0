Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:36429 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbcEBSkd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:40:33 -0400
Subject: [PATCH v3 02/20] sunrpc: Update RPCBIND_MAXNETIDLEN
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:40:31 -0400
Message-ID: <20160502184031.10798.63289.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 176e21ee2ec8 ("SUNRPC: Support for RPC over AF_LOCAL
transports") added a 5-character netid, but did not bump
RPCBIND_MAXNETIDLEN from 4 to 5.

Fixes: 176e21ee2ec8 ("SUNRPC: Support for RPC over AF_LOCAL ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/msg_prot.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
index 8073713..59cbf16 100644
--- a/include/linux/sunrpc/msg_prot.h
+++ b/include/linux/sunrpc/msg_prot.h
@@ -158,9 +158,9 @@ typedef __be32	rpc_fraghdr;
 
 /*
  * Note that RFC 1833 does not put any size restrictions on the
- * netid string, but all currently defined netid's fit in 4 bytes.
+ * netid string, but all currently defined netid's fit in 5 bytes.
  */
-#define RPCBIND_MAXNETIDLEN	(4u)
+#define RPCBIND_MAXNETIDLEN	(5u)
 
 /*
  * Universal addresses are introduced in RFC 1833 and further spelled

