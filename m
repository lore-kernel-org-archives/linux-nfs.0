Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9139 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756437Ab1EWQix (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:38:53 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v6 22/26] pnfs: layoutret_on_setattr
Date: Mon, 23 May 2011 19:38:46 +0300
Message-Id: <1306168726-11757-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

With the objects layout security model, we have object capabilities
that are associated with the layout and we anticipate that the server
will issue a cb_layoutrecall for any setattr that changes security
related attributes (user/group/mode/acl) or truncates the file.

Therefore, the layout is returned before issuing the setattr to avoid
the anticipated cb_layoutrecall.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c            |    3 +++
 fs/nfs/objlayout/objio_osd.c |    1 +
 fs/nfs/pnfs.h                |   22 ++++++++++++++++++++++
 3 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5b4124e..5734009 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2361,6 +2361,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_state *state = NULL;
 	int status;
 
+	if (pnfs_ld_layoutret_on_setattr(inode))
+		pnfs_return_layout(inode);
+
 	nfs_fattr_init(fattr);
 	
 	/* Search for an existing open(O_WRITE) file */
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 04fc2bf..95fb687 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -950,6 +950,7 @@ objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 static struct pnfs_layoutdriver_type objlayout_type = {
 	.id = LAYOUT_OSD2_OBJECTS,
 	.name = "LAYOUT_OSD2_OBJECTS",
+	.flags                   = PNFS_LAYOUTRET_ON_SETATTR,
 
 	.alloc_layout_hdr        = objlayout_alloc_layout_hdr,
 	.free_layout_hdr         = objlayout_free_layout_hdr,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 21daebb..2858553 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,6 +65,11 @@ enum {
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 };
 
+enum layoutdriver_policy_flags {
+	/* Should the pNFS client commit and return the layout upon a setattr */
+	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
+};
+
 struct nfs4_deviceid_node;
 
 /* Per-layout driver specific registration structure */
@@ -73,6 +78,7 @@ struct pnfs_layoutdriver_type {
 	const u32 id;
 	const char *name;
 	struct module *owner;
+	unsigned flags;
 
 	struct pnfs_layout_hdr * (*alloc_layout_hdr) (struct inode *inode, gfp_t gfp_flags);
 	void (*free_layout_hdr) (struct pnfs_layout_hdr *);
@@ -258,6 +264,16 @@ static inline void pnfs_clear_request_commit(struct nfs_page *req)
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
@@ -317,6 +333,12 @@ static inline int pnfs_return_layout(struct inode *ino)
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

