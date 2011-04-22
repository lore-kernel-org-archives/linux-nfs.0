Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6577 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab1DVIMI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:12:08 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd-lexp: simulate layout segments
Date: Fri, 22 Apr 2011 11:11:58 +0300
Message-Id: <1303459918-20327-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/Kconfig      |   20 ++++++++++++++++++++
 fs/nfsd/pnfsd_lexp.c |   12 +++++++++++-
 2 files changed, 31 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 82f46bb..d0f8527 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -113,3 +113,23 @@ config PNFSD_LOCAL_EXPORT
 	  useful for development and debugging purposes.
 
 	  If unsure, say N.
+
+config PNFSD_LEXP_LAYOUT_SEGMENTS
+	bool "Simulate layout segments"
+	depends on PNFSD_LOCAL_EXPORT
+	help
+	  Say Y here if you want your pNFS server to simulate layout segments
+	  when exporting local filesystems for debugging purposes.
+	  over the files layout type.
+	  This is mostly useful for development and debugging purposes.
+
+	  If unsure, say N.
+
+config PNFSD_LEXP_LAYOUT_SEGMENT_SIZE
+	int "Simulated layout segment size"
+	depends on PNFSD_LEXP_LAYOUT_SEGMENTS
+	default 65536
+	help
+	  Set simulated layout segment size.
+
+	  If unsure, say N.
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index e9382da..5610490 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -143,8 +143,16 @@ pnfsd_lexp_layout_get(struct inode *inode,
 	dprintk("--> %s: inode=%p\n", __func__, inode);
 
 	res->lg_seg.layout_type = LAYOUT_NFSV4_1_FILES;
+#ifdef     CONFIG_PNFSD_LEXP_LAYOUT_SEGMENTS
+#if CONFIG_PNFSD_LEXP_LAYOUT_SEGMENT_SIZE <= 0
+#error CONFIG_PNFSD_LEXP_LAYOUT_SEGMENT_SIZE must be greater than zero
+#endif
+	res->lg_seg.offset -= res->lg_seg.offset % CONFIG_PNFSD_LEXP_LAYOUT_SEGMENT_SIZE;
+	res->lg_seg.length = CONFIG_PNFSD_LEXP_LAYOUT_SEGMENT_SIZE;
+#else   /* CONFIG_PNFSD_LEXP_LAYOUT_SEGMENTS */
 	res->lg_seg.offset = 0;
 	res->lg_seg.length = NFS4_MAX_UINT64;
+#endif  /* CONFIG_PNFSD_LEXP_LAYOUT_SEGMENTS */
 
 	layout = kzalloc(sizeof(*layout), GFP_KERNEL);
 	if (layout == NULL) {
@@ -178,7 +186,9 @@ pnfsd_lexp_layout_get(struct inode *inode,
 exit:
 	kfree(layout);
 	kfree(fhp);
-	dprintk("<-- %s: return %d\n", __func__, rc);
+	dprintk("<-- %s: return %d offset=%llu length=%llu\n", __func__, rc,
+		(unsigned long long)res->lg_seg.offset,
+		(unsigned long long)res->lg_seg.length);
 	return rc;
 
 error:
-- 
1.7.3.4

