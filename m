From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 07/85] nfs41: define NFS4_MAX_MINOR_VERSION based on CONFIG_NFS_V4_1
Date: Mon, 10 Nov 2008 22:19:02 +0200
Message-ID: <1226348342-7237-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60703 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbYKJUTH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:19:07 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
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
index bdcd316..a69bbfa 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -435,6 +435,13 @@ enum lock_type4 {
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
 #define NFS4_MINOR_VERSION 1
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
1.6.0.2

