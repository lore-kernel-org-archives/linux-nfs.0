Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009Ab2BFXuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 18:50:07 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Change the default limit to the number of TCP slots
Date: Mon,  6 Feb 2012 18:49:45 -0500
Message-Id: <1328572185-2568-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the scheme of limiting the number of TCP slots to whatever will
fit in the current TCP window seems to be working well (Andy reports
getting within 20% of the 'iperf' send performance on a 10GigE link)
we should just let that be the default mode of operation.

Users may still set their own limits using the tcp_max_slot_table_entries
parameter if they need to.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/nfs_fs_sb.h   |    2 +-
 include/linux/sunrpc/xprt.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c234693..9e101c1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -190,7 +190,7 @@ struct nfs_server {
 
 
 /* maximum number of slots to use */
-#define NFS4_MAX_SLOT_TABLE RPC_MAX_SLOT_TABLE
+#define NFS4_MAX_SLOT_TABLE (128U)
 
 #if defined(CONFIG_NFS_V4)
 
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 15518a1..b033f36 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -21,8 +21,8 @@
 
 #define RPC_MIN_SLOT_TABLE	(2U)
 #define RPC_DEF_SLOT_TABLE	(16U)
-#define RPC_MAX_SLOT_TABLE	(128U)
 #define RPC_MAX_SLOT_TABLE_LIMIT	(65536U)
+#define RPC_MAX_SLOT_TABLE	RPC_MAX_SLOT_TABLE_LIMIT
 
 /*
  * This describes a timeout strategy
-- 
1.7.7.6

