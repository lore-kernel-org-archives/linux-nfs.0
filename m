Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51183 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaHUQHa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:30 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtd-00009V-0B
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:29 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/19] pnfs: avoid using stale stateids after layoutreturn
Date: Thu, 21 Aug 2014 11:09:22 -0500
Message-Id: <1408637375-11343-7-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After we issued a layoutreturn operations the may free the layout stateid
and will thus cause bad stateid error when the client uses it again.

We currently try to avoid this case by chosing the open stateid if not
lsegs are present for this inode.  But various places can hold refererence
on lsegs and thus cause the list not to be empty shortly after a layout
return.  Add an explicit flag to mark the current layout stateid invalid
and force usage of the openstateid after we did a full file layoutreturn.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pnfs.c | 7 ++++++-
 fs/nfs/pnfs.h | 1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 32a14a6..bce7f1b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -741,7 +741,8 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 		status = -EAGAIN;
 	} else if (!nfs4_valid_open_stateid(open_state)) {
 		status = -EBADF;
-	} else if (list_empty(&lo->plh_segs)) {
+	} else if (list_empty(&lo->plh_segs) ||
+		   test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags)) {
 		int seq;
 
 		do {
@@ -863,6 +864,8 @@ _pnfs_return_layout(struct inode *ino)
 		dprintk("NFS: %s no layout segments to return\n", __func__);
 		goto out;
 	}
+
+	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 	lo->plh_block_lgets++;
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
@@ -1383,6 +1386,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		lo->plh_barrier = be32_to_cpu(res->stateid.seqid);
 	}
 
+	clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+
 	pnfs_get_lseg(lseg);
 	pnfs_layout_insert_lseg(lo, lseg);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index aca3dff..16cd14f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,6 +65,7 @@ enum {
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
+	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 };
 
 enum layoutdriver_policy_flags {
-- 
1.9.1

