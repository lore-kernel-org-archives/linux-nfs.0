Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36064 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbcADSVy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:54 -0500
Received: by mail-ig0-f181.google.com with SMTP id ph11so250741033igc.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:53 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/18] NFSv4.1/pNFS: Don't pass stateids by value to pnfs_send_layoutreturn()
Date: Mon,  4 Jan 2016 13:21:09 -0500
Message-Id: <1451931676-68481-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-10-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A stateid is a structure, pass it as a pointer.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6593be7c0129..7a452895169f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -53,7 +53,7 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
 static LIST_HEAD(pnfs_modules_tbl);
 
 static int
-pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
+pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 		       enum pnfs_iomode iomode, bool sync);
 
 /* Return the registered pnfs layout driver module matching given id */
@@ -391,7 +391,7 @@ static void pnfs_layoutreturn_before_put_lseg(struct pnfs_layout_segment *lseg,
 		spin_unlock(&inode->i_lock);
 		if (send) {
 			/* Send an async layoutreturn so we dont deadlock */
-			pnfs_send_layoutreturn(lo, stateid, iomode, false);
+			pnfs_send_layoutreturn(lo, &stateid, iomode, false);
 		}
 	} else
 		spin_unlock(&inode->i_lock);
@@ -947,7 +947,7 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 }
 
 static int
-pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
+pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, const nfs4_stateid *stateid,
 		       enum pnfs_iomode iomode, bool sync)
 {
 	struct inode *ino = lo->plh_inode;
@@ -964,7 +964,7 @@ pnfs_send_layoutreturn(struct pnfs_layout_hdr *lo, nfs4_stateid stateid,
 		goto out;
 	}
 
-	lrp->args.stateid = stateid;
+	nfs4_stateid_copy(&lrp->args.stateid, stateid);
 	lrp->args.layout_type = NFS_SERVER(ino)->pnfs_curr_ld->id;
 	lrp->args.inode = ino;
 	lrp->args.range.iomode = iomode;
@@ -1035,7 +1035,7 @@ _pnfs_return_layout(struct inode *ino)
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 	if (send)
-		status = pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
+		status = pnfs_send_layoutreturn(lo, &stateid, IOMODE_ANY, true);
 out_put_layout_hdr:
 	pnfs_put_layout_hdr(lo);
 out:
@@ -1126,7 +1126,7 @@ out_noroc:
 	pnfs_free_lseg_list(&tmp_list);
 	pnfs_layoutcommit_inode(ino, true);
 	if (layoutreturn)
-		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
+		pnfs_send_layoutreturn(lo, &stateid, IOMODE_ANY, true);
 	return roc;
 }
 
-- 
2.5.0

