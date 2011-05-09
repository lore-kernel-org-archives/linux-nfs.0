Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38038 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab1EIRKa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:10:30 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 21/29] pnfs: layoutret_on_setattr
Date: Mon,  9 May 2011 20:10:23 +0300
Message-Id: <1304961023-4569-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c            |    3 +++
 fs/nfs/objlayout/objio_osd.c |    1 +
 fs/nfs/pnfs.h                |   22 ++++++++++++++++++++++
 3 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 05ed4c8..faa1240 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2332,6 +2332,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_state *state = NULL;
 	int status;
 
+	if (pnfs_ld_layoutret_on_setattr(inode))
+		pnfs_return_layout(inode);
+
 	nfs_fattr_init(fattr);
 	
 	/* Search for an existing open(O_WRITE) file */
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 93b9580..c47c953 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -716,6 +716,7 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
+	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
 
 	.set_layoutdriver        = objlayout_set_layoutdriver,
 	.unset_layoutdriver      = objlayout_unset_layoutdriver,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 63f51b7..a54e715 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,12 +65,18 @@ enum {
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
 
 	int (*set_layoutdriver) (struct nfs_server *);
 	int (*unset_layoutdriver) (struct nfs_server *);
@@ -238,6 +244,16 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
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
 static inline int pnfs_return_layout(struct inode *ino)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
@@ -296,6 +312,12 @@ static inline int pnfs_return_layout(struct inode *ino)
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

