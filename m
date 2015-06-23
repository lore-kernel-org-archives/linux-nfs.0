Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34141 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbbFWLwv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2015 07:52:51 -0400
Received: by pabvl15 with SMTP id vl15so5668214pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Jun 2015 04:52:51 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH-v2 09/10] nfs42: serialize LAYOUTSTATS calls of the same file
Date: Tue, 23 Jun 2015 19:52:03 +0800
Message-Id: <1435060324-13279-10-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
References: <1435060324-13279-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no need to report concurrently.

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42proc.c     | 3 +++
 fs/nfs/pnfs.c          | 7 +++++++
 include/linux/nfs_fs.h | 1 +
 3 files changed, 11 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ee02483..06c74cd 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -204,6 +204,9 @@ nfs42_layoutstat_release(void *calldata)
 		nfss->pnfs_curr_ld->cleanup_layoutstats(data);
 
 	pnfs_put_layout_hdr(NFS_I(data->args.inode)->layout);
+	smp_mb__before_atomic();
+	clear_bit(NFS_INO_LAYOUTSTATS, &NFS_I(data->args.inode)->flags);
+	smp_mb__after_atomic();
 	nfs_iput_and_deactive(data->inode);
 	kfree(data->args.devinfo);
 	kfree(data);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 389f7c9..e5bd626 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2254,6 +2254,7 @@ pnfs_report_layoutstat(struct inode *inode)
 {
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs42_layoutstat_data *data;
 	struct pnfs_layout_hdr *hdr;
 	int status = 0;
@@ -2261,6 +2262,9 @@ pnfs_report_layoutstat(struct inode *inode)
 	if (!pnfs_enabled_sb(server) || !ld->prepare_layoutstats)
 		goto out;
 
+	if (test_and_set_bit(NFS_INO_LAYOUTSTATS, &nfsi->flags))
+		goto out;
+
 	spin_lock(&inode->i_lock);
 	if (!NFS_I(inode)->layout) {
 		spin_unlock(&inode->i_lock);
@@ -2293,6 +2297,9 @@ out_free:
 	kfree(data);
 out_put:
 	pnfs_put_layout_hdr(hdr);
+	smp_mb__before_atomic();
+	clear_bit(NFS_INO_LAYOUTSTATS, &nfsi->flags);
+	smp_mb__after_atomic();
 	goto out;
 }
 EXPORT_SYMBOL_GPL(pnfs_report_layoutstat);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b95f914..f91b5ad 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -219,6 +219,7 @@ struct nfs_inode {
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
+#define NFS_INO_LAYOUTSTATS	(11)		/* layoutstats inflight */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
-- 
1.8.3.1

