From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 03/46] nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
Date: Wed,  4 Mar 2009 01:52:11 +0200
Message-ID: <1236124331-3063-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17317
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755728AbZCCXwV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:52:21 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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
index a64b41c..696cbec 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -448,6 +448,13 @@ enum lock_type4 {
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
1.6.1.3

