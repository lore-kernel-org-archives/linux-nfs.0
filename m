From: andros@netapp.com
Subject: [PATCH 4/5] post-submit: restore and fix layoutret_on_setattr
Date: Wed, 14 Jul 2010 15:43:57 -0400
Message-ID: <1279136638-3097-4-git-send-email-andros@netapp.com>
References: <1279136638-3097-1-git-send-email-andros@netapp.com>
 <1279136638-3097-2-git-send-email-andros@netapp.com>
 <1279136638-3097-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236Ab0GNTn5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jul 2010 15:43:57 -0400
In-Reply-To: <1279136638-3097-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Add pnfs_enabled_sb check

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |    3 +++
 fs/nfs/pnfs.h             |   10 ++++++++++
 include/linux/nfs4_pnfs.h |    7 +++++++
 3 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 756f6e9..288025e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2358,6 +2358,9 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	struct nfs4_state *state = NULL;
 	int status;
 
+	if (pnfs_ld_layoutret_on_setattr(inode))
+		pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
+
 	nfs_fattr_init(fattr);
 	
 	/* Search for an existing open(O_WRITE) file */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6bc27af..d5dc2e2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -92,6 +92,16 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
+/* Should the pNFS client commit and return the layout upon a setattr */
+static inline bool
+pnfs_ld_layoutret_on_setattr(struct inode *inode)
+{
+	if (!pnfs_enabled_sb(NFS_SERVER(inode)))
+		return false;
+	return NFS_SERVER(inode)->pnfs_curr_ld->ld_policy_ops->flags &
+		PNFS_LAYOUTRET_ON_SETATTR;
+}
+
 /* Should the pNFS client commit and return the layout on close
  */
 static inline int
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 52fe384..eb9dfe4 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -155,7 +155,14 @@ struct layoutdriver_io_operations {
 	int (*uninitialize_mountpoint) (struct nfs_server *server);
 };
 
+enum layoutdriver_policy_flags {
+	/* Should the pNFS client commit and return the layout upon a setattr */
+	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 3,
+};
+
 struct layoutdriver_policy_operations {
+	unsigned flags;
+
 	/* The stripe size of the file system */
 	ssize_t (*get_stripesize) (struct pnfs_layout_type *layoutid);
 
-- 
1.6.6

