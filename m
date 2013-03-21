Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:61005 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757636Ab3CUONH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:13:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>, Boaz Harrosh <bharrosh@panasas.com>,
        Peng Tao <bergwolf@gmail.com>
Subject: [PATCH v2 3/3] NFSv4.1: Add a helper pnfs_commit_and_return_layout
Date: Thu, 21 Mar 2013 10:13:01 -0400
Message-Id: <1363875181-7147-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363875181-7147-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1363875181-7147-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363875181-7147-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to be able to safely return the layout in nfs4_proc_setattr,
we need to block new uses of the layout, wait for all outstanding
users of the layout to complete, commit the layout and then return it.

This patch adds a helper in order to do all this safely.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4proc.c |  2 +-
 fs/nfs/pnfs.c     | 27 +++++++++++++++++++++++++++
 fs/nfs/pnfs.h     |  6 ++++++
 3 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6ccdd4f..26431cf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2632,7 +2632,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	int status;
 
 	if (pnfs_ld_layoutret_on_setattr(inode))
-		pnfs_return_layout(inode);
+		pnfs_commit_and_return_layout(inode);
 
 	nfs_fattr_init(fattr);
 	
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b9d0682..2b5d98e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -866,6 +866,33 @@ out:
 }
 EXPORT_SYMBOL_GPL(_pnfs_return_layout);
 
+int
+pnfs_commit_and_return_layout(struct inode *inode)
+{
+	struct pnfs_layout_hdr *lo;
+	int ret;
+
+	spin_lock(&inode->i_lock);
+	lo = NFS_I(inode)->layout;
+	if (lo == NULL) {
+		spin_unlock(&inode->i_lock);
+		return 0;
+	}
+	pnfs_get_layout_hdr(lo);
+	/* Block new layoutgets and read/write to ds */
+	lo->plh_block_lgets++;
+	spin_unlock(&inode->i_lock);
+	filemap_fdatawait(inode->i_mapping);
+	ret = pnfs_layoutcommit_inode(inode, true);
+	if (ret == 0)
+		ret = _pnfs_return_layout(inode);
+	spin_lock(&inode->i_lock);
+	lo->plh_block_lgets--;
+	spin_unlock(&inode->i_lock);
+	pnfs_put_layout_hdr(lo);
+	return ret;
+}
+
 bool pnfs_roc(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 94ba804..f5f8a47 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -219,6 +219,7 @@ void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
+int pnfs_commit_and_return_layout(struct inode *);
 void pnfs_ld_write_done(struct nfs_write_data *);
 void pnfs_ld_read_done(struct nfs_read_data *);
 struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
@@ -407,6 +408,11 @@ static inline int pnfs_return_layout(struct inode *ino)
 	return 0;
 }
 
+static inline int pnfs_commit_and_return_layout(struct inode *inode)
+{
+	return 0;
+}
+
 static inline bool
 pnfs_ld_layoutret_on_setattr(struct inode *inode)
 {
-- 
1.8.1.4

