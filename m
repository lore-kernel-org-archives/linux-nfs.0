Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57083 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab1DTR0q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:26:46 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 04/27] pnfs: layoutret_on_setattr
Date: Wed, 20 Apr 2011 20:26:41 +0300
Message-Id: <1303320401-21106-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 fs/nfs/pnfs.h     |   22 ++++++++++++++++++++++
 2 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b03defb..b4df7a6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2332,6 +2332,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_state *state = NULL;
 	int status;
 
+	if (pnfs_ld_layoutret_on_setattr(inode))
+		pnfs_return_layout(inode, NULL, true);
+
 	nfs_fattr_init(fattr);
 	
 	/* Search for an existing open(O_WRITE) file */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a308f3c..3506ad4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,12 +64,18 @@ enum {
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 };
 
+enum layoutdriver_policy_flags {
+	/* Should the pNFS client commit and return the layout upon a setattr */
+	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
+};
+
 /* Per-layout driver specific registration structure */
 struct pnfs_layoutdriver_type {
 	struct list_head pnfs_tblid;
 	const u32 id;
 	const char *name;
 	struct module *owner;
+	unsigned flags;
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
@@ -228,6 +234,16 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
 		put_lseg(req->wb_commit_lseg);
 }
 
+/* Should the pNFS client commit and return the layout upon a setattr */
+static inline bool
+pnfs_ld_layoutret_on_setattr(struct inode *inode)
+{
+	if (!pnfs_enabled_sb(NFS_SERVER(inode)))
+		return false;
+	return NFS_SERVER(inode)->pnfs_curr_ld->flags &
+		PNFS_LAYOUTRET_ON_SETATTR;
+}
+
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
 				     bool wait)
@@ -290,6 +306,12 @@ static inline int pnfs_return_layout(struct inode *ino,
 }
 
 static inline bool
+pnfs_ld_layoutret_on_setattr(struct inode *inode)
+{
+	return false;
+}
+
+static inline bool
 pnfs_roc(struct inode *ino)
 {
 	return false;
-- 
1.7.3.4

