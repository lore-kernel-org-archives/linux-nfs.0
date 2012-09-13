Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36102 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759113Ab2IMXhM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Sep 2012 19:37:12 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCH 06/10] SQUASHME: pnfsd: layout_return API changes
Date: Fri, 14 Sep 2012 02:37:00 +0300
Message-ID: <1347579420-21617-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <50526B39.3000802@panasas.com>
References: <50526B39.3000802@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the layout_return API is changes, to fix member
naming, and fix all users.

Exofs is not yet using the new lo_cookie only
the fact that it is no empty.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c               | 11 +++++++----
 fs/nfsd/nfs4pnfsd.c             |  2 +-
 include/linux/nfsd/nfsd4_pnfs.h |  2 +-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 621bd11..809fa19 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -126,6 +126,7 @@ static enum nfsstat4 exofs_layout_get(
 	_align_io(&sbi->layout, &res->lg_seg.offset, &res->lg_seg.length);
 	res->lg_seg.iomode = IOMODE_RW;
 	res->lg_return_on_close = true;
+	res->lg_lo_cookie = inode; /* Just for debug prints */
 
 	EXOFS_DBGMSG("(0x%lx) RETURNED offset=0x%llx len=0x%llx iomod=0x%x\n",
 		     inode->i_ino, res->lg_seg.offset,
@@ -292,19 +293,21 @@ static int exofs_layout_return(
 	};
 	struct pnfs_osd_ioerr ioerr;
 
-	EXOFS_DBGMSG("(0x%lx) cookie %p body_len %d\n",
-		     inode->i_ino, args->lr_cookie, args->lrf_body_len);
+	EXOFS_DBGMSG("(0x%lx) lo_cookie=%p cb_cookie=%p empty=%d body_len %d\n",
+		     inode->i_ino, args->lr_lo_cookie, args->lr_cb_cookie,
+		     args->lr_empty, args->lrf_body_len);
 
 	while (pnfs_osd_xdr_decode_ioerr(&ioerr, &xdr))
 		exofs_handle_error(&ioerr);
 
-	if (args->lr_cookie) {
+	if (args->lr_cb_cookie || args->lr_empty) {
 		struct exofs_i_info *oi = exofs_i(inode);
 		bool in_recall;
 
 		spin_lock(&oi->i_layout_lock);
 		in_recall = test_bit(OBJ_IN_LAYOUT_RECALL, &oi->i_flags);
-		__clear_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags);
+		if (args->lr_empty)
+			__clear_bit(OBJ_LAYOUT_IS_GIVEN, &oi->i_flags);
 		spin_unlock(&oi->i_layout_lock);
 
 		/* TODO: how to communicate cookie with the waiter */
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index e0ad1d7..e8e7709 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -359,7 +359,7 @@ void fs_layout_return(struct inode *ino, struct nfsd4_pnfs_layoutreturn *lrp,
 	if (unlikely(!sb->s_pnfs_op->layout_return))
 		return;
 
-	lrp->args.lr_cookie = recall_cookie;
+	lrp->args.lr_cb_cookie = recall_cookie;
 	lrp->args.lr_lo_cookie = lo_cookie;
 	lrp->args.lr_empty = empty;
 
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index a35b93e..6bd03f9 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -119,7 +119,7 @@ struct nfsd4_pnfs_layoutreturn_arg {
 	u32			lr_reclaim;	/* request */
 	u32			lrf_body_len;	/* request */
 	void			*lrf_body;	/* request */
-	void			*lr_cookie;	/* fs private */
+	void			*lr_cb_cookie;	/* fs private */
 	void			*lr_lo_cookie;	/* fs private */
 	bool			lr_empty;	/* request */
 };
-- 
1.7.10.2.677.gb6bc67f

