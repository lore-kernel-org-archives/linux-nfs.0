From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 03/67] nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
Date: Thu,  2 Apr 2009 16:50:54 +0300
Message-ID: <1238680254-13494-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1435 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754037AbZDBNvE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:04 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mike Sager <sager@netapp.com>

If 4.1 isn't supported, NFS4_MAX_MINOR_VERSION will be 0.

Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs4.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 29ed600..c0c1e8e 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -454,6 +454,13 @@ enum lock_type4 {
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
 #define NFS4_MINOR_VERSION 0
+
+#if defined(CONFIG_NFS_V4_1)
+#define NFS4_MAX_MINOR_VERSION 1
+#else
+#define NFS4_MAX_MINOR_VERSION 0
+#endif /* CONFIG_NFS_V4_1 */
+
 #define NFS4_DEBUG 1
 
 /* Index of predefined Linux client operations */
-- 
1.6.2.1

