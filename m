Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38925 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab1EVQxP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 12:53:15 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 19/23] pnfs: layoutret_on_setattr
Date: Sun, 22 May 2011 19:52:55 +0300
Message-Id: <1306083175-11143-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD93D3E.9010909@panasas.com>
References: <4DD93D3E.9010909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

objlayout protocol recommends to proactively return layouts
on set_attr. Because otherwise the Server will recall them
anyway.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c            |    3 +++
 fs/nfs/objlayout/objio_osd.c |    1 +
 fs/nfs/pnfs.h                |   22 ++++++++++++++++++++++
 3 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ded697..28ed8c6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2360,6 +2360,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_state *state = NULL;
 	int status;
 
+	if (pnfs_ld_layoutret_on_setattr(inode))
+		pnfs_return_layout(inode);
+
 	nfs_fattr_init(fattr);
 	
 	/* Search for an existing open(O_WRITE) file */
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 3a93504..ae987a0 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -953,6 +953,7 @@ ssize_t objio_write_pagelist(struct objlayout_io_state *ol_state, bool stable)
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
1.7.2.3

