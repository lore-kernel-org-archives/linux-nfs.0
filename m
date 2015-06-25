Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36294 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754349AbbFYKUJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 06:20:09 -0400
Received: by pdcu2 with SMTP id u2so50730296pdc.3
        for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2015 03:20:08 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] nfs: provide pnfs_report_layoutstat when NFS42 is disabled
Date: Thu, 25 Jun 2015 18:19:32 +0800
Message-Id: <1435227572-75919-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kbuild test robot reported:
   fs/built-in.o: In function `pnfs_report_layoutstat':
>> (.text+0x151a1c): undefined reference to `nfs42_proc_layoutstats_generic'

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c |  2 ++
 fs/nfs/pnfs.h | 12 ++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e5bd626..546cbbe 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2249,6 +2249,7 @@ struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 	return thp;
 }
 
+#if IS_ENABLED(CONFIG_NFS_V4_2)
 int
 pnfs_report_layoutstat(struct inode *inode)
 {
@@ -2303,3 +2304,4 @@ out_put:
 	goto out;
 }
 EXPORT_SYMBOL_GPL(pnfs_report_layoutstat);
+#endif
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0a47239..3e6ab7b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -292,8 +292,6 @@ int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *);
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 void pnfs_error_mark_layout_for_return(struct inode *inode,
 				       struct pnfs_layout_segment *lseg);
-int pnfs_report_layoutstat(struct inode *inode);
-
 /* nfs4_deviceid_flags */
 enum {
 	NFS_DEVICEID_INVALID = 0,       /* set when MDS clientid recalled */
@@ -692,4 +690,14 @@ static inline void nfs4_pnfs_v3_ds_connect_unload(void)
 
 #endif /* CONFIG_NFS_V4_1 */
 
+#if IS_ENABLED(CONFIG_NFS_V4_2)
+int pnfs_report_layoutstat(struct inode *inode);
+#else
+static inline int
+pnfs_report_layoutstat(struct inode *inode)
+{
+	return 0;
+}
+#endif
+
 #endif /* FS_NFS_PNFS_H */
-- 
1.8.3.1

