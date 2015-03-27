Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35888 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbbC0RC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:02:58 -0400
Received: by iedm5 with SMTP id m5so75465749ied.3
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:02:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pnfs: Fix setting of layoutcommit last write byte
Date: Fri, 27 Mar 2015 13:02:55 -0400
Message-Id: <1427475775-14495-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the NFS_INO_LAYOUTCOMMIT flag was unset, then we _must_ ensure that
we also reset the last write byte (lwb) for that layout. The current
code depends on us clearing the lwb when we clear NFS_INO_LAYOUTCOMMIT,
which is not the case when we call pnfs_clear_layoutcommit().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f802b02fbb9..b96736df98e8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2108,16 +2108,16 @@ pnfs_set_layoutcommit(struct nfs_pgio_header *hdr)
 
 	spin_lock(&inode->i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
+		nfsi->layout->plh_lwb = end_pos;
 		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, inode->i_ino);
-	}
+	} else if (end_pos > nfsi->layout->plh_lwb)
+		nfsi->layout->plh_lwb = end_pos;
 	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &hdr->lseg->pls_flags)) {
 		/* references matched in nfs4_layoutcommit_release */
 		pnfs_get_lseg(hdr->lseg);
 	}
-	if (end_pos > nfsi->layout->plh_lwb)
-		nfsi->layout->plh_lwb = end_pos;
 	spin_unlock(&inode->i_lock);
 	dprintk("%s: lseg %p end_pos %llu\n",
 		__func__, hdr->lseg, nfsi->layout->plh_lwb);
@@ -2137,16 +2137,16 @@ void pnfs_commit_set_layoutcommit(struct nfs_commit_data *data)
 
 	spin_lock(&inode->i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
+		nfsi->layout->plh_lwb = data->lwb;
 		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, inode->i_ino);
-	}
+	} else if (data->lwb > nfsi->layout->plh_lwb)
+		nfsi->layout->plh_lwb = data->lwb;
 	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &data->lseg->pls_flags)) {
 		/* references matched in nfs4_layoutcommit_release */
 		pnfs_get_lseg(data->lseg);
 	}
-	if (data->lwb > nfsi->layout->plh_lwb)
-		nfsi->layout->plh_lwb = data->lwb;
 	spin_unlock(&inode->i_lock);
 	dprintk("%s: lseg %p end_pos %llu\n",
 		__func__, data->lseg, nfsi->layout->plh_lwb);
@@ -2216,7 +2216,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	pnfs_list_write_lseg(inode, &data->lseg_list);
 
 	end_pos = nfsi->layout->plh_lwb;
-	nfsi->layout->plh_lwb = 0;
 
 	nfs4_stateid_copy(&data->args.stateid, &nfsi->layout->plh_stateid);
 	spin_unlock(&inode->i_lock);
@@ -2233,11 +2232,11 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 		status = ld->prepare_layoutcommit(&data->args);
 		if (status) {
 			spin_lock(&inode->i_lock);
-			if (end_pos < nfsi->layout->plh_lwb)
+			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
+			if (end_pos > nfsi->layout->plh_lwb)
 				nfsi->layout->plh_lwb = end_pos;
 			spin_unlock(&inode->i_lock);
 			put_rpccred(data->cred);
-			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
 			goto clear_layoutcommitting;
 		}
 	}
-- 
2.1.0

