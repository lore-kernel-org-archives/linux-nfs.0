From: andros@netapp.com
Subject: [PATCH 12/16] SQUASHME pnfs-submit: reference layout across layoutcommit
Date: Wed,  7 Jul 2010 18:34:19 -0400
Message-ID: <1278542063-4009-13-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
 <1278542063-4009-5-git-send-email-andros@netapp.com>
 <1278542063-4009-6-git-send-email-andros@netapp.com>
 <1278542063-4009-7-git-send-email-andros@netapp.com>
 <1278542063-4009-8-git-send-email-andros@netapp.com>
 <1278542063-4009-9-git-send-email-andros@netapp.com>
 <1278542063-4009-10-git-send-email-andros@netapp.com>
 <1278542063-4009-11-git-send-email-andros@netapp.com>
 <1278542063-4009-12-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757687Ab0GGWeb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:31 -0400
In-Reply-To: <1278542063-4009-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 fs/nfs/pnfs.c     |   13 +++++++++++++
 fs/nfs/pnfs.h     |    1 +
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6acebc3..f763746 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5565,6 +5565,8 @@ static void pnfs_layoutcommit_release(void *lcdata)
 	struct pnfs_layoutcommit_data *data =
 		(struct pnfs_layoutcommit_data *)lcdata;
 
+	/* Matched by get_layout in pnfs_layoutcommit_inode */
+	put_layout(data->args.inode);
 	put_rpccred(data->cred);
 	pnfs_layoutcommit_free(lcdata);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index aa16e5d..d42c5da 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -354,6 +354,15 @@ put_layout_locked(struct pnfs_layout_type *lo)
 }
 
 void
+put_layout(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	put_layout_locked(NFS_I(inode)->layout);
+	spin_unlock(&inode->i_lock);
+
+}
+
+void
 pnfs_layout_release(struct pnfs_layout_type *lo,
 		    struct nfs4_pnfs_layout_segment *range)
 {
@@ -1598,6 +1607,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	__clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
 	pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout);
 
+	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
+	get_layout(NFS_I(inode)->layout);
+
 	spin_unlock(&inode->i_lock);
 
 	/* Set up layout commit args */
@@ -1606,6 +1618,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	if (status) {
 		/* The layout driver failed to setup the layoutcommit */
 		put_rpccred(data->cred);
+		put_layout(inode);
 		goto out_free;
 	}
 	status = pnfs4_proc_layoutcommit(data, sync);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9b0fed4..e04b9d4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,6 +64,7 @@ void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segm
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
+void put_layout(struct inode *inode);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
-- 
1.6.6

