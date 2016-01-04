Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36585 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbcADSV4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:56 -0500
Received: by mail-io0-f173.google.com with SMTP id o67so442621433iof.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:56 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 14/18] NFSv4.1/pNFS: pnfs_error_mark_layout_for_return() must always return layout
Date: Mon,  4 Jan 2016 13:21:12 -0500
Message-Id: <1451931676-68481-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-13-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-4-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-5-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-6-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-7-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-8-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-9-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-12-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-13-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a bug whereby if all the layout segments could be immediately freed,
the call to pnfs_error_mark_layout_for_return() would never result in
a layoutreturn.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 26 ++++++++++++++++++++------
 fs/nfs/pnfs.h |  2 +-
 2 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 449c4782cab3..8e1d4229bf2d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1768,17 +1768,18 @@ pnfs_set_plh_return_iomode(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode)
 	lo->plh_return_iomode = iomode;
 }
 
-void
+int
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *return_range)
 {
 	struct pnfs_layout_segment *lseg, *next;
+	int remaining = 0;
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
 	if (list_empty(&lo->plh_segs))
-		return;
+		return 0;
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
 
@@ -1791,10 +1792,12 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				lseg->pls_range.length);
 			set_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags);
 			pnfs_set_plh_return_iomode(lo, return_range->iomode);
-			mark_lseg_invalid(lseg, tmp_list);
+			if (!mark_lseg_invalid(lseg, tmp_list))
+				remaining++;
 			set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
 					&lo->plh_flags);
 		}
+	return remaining;
 }
 
 void pnfs_error_mark_layout_for_return(struct inode *inode,
@@ -1808,6 +1811,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 		.length = NFS4_MAX_UINT64,
 	};
 	LIST_HEAD(free_me);
+	bool return_now = false;
 
 	spin_lock(&inode->i_lock);
 	/* set failure bit so that pnfs path will be retried later */
@@ -1818,10 +1822,20 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
 	 * for how it works.
 	 */
-	pnfs_mark_matching_lsegs_return(lo, &free_me, &range);
-	spin_unlock(&inode->i_lock);
+	if (!pnfs_mark_matching_lsegs_return(lo, &free_me, &range)) {
+		nfs4_stateid stateid;
+		enum pnfs_iomode iomode = lo->plh_return_iomode;
+
+		nfs4_stateid_copy(&stateid, &lo->plh_stateid);
+		return_now = pnfs_prepare_layoutreturn(lo);
+		spin_unlock(&inode->i_lock);
+		if (return_now)
+			pnfs_send_layoutreturn(lo, &stateid, iomode, false);
+	} else {
+		spin_unlock(&inode->i_lock);
+		nfs_commit_inode(inode, 0);
+	}
 	pnfs_free_lseg_list(&free_me);
-	nfs_commit_inode(inode, 0);
 }
 EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4bd7faf9ce50..3d0f513a4a77 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -266,7 +266,7 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *recall_range);
-void pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
+int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *recall_range);
 bool pnfs_roc(struct inode *ino);
-- 
2.5.0

