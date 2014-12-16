Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:52168 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaLPTDS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:03:18 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so14658485pad.37
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:03:18 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 39/50] nfs/flexfiles: send layoutreturn before freeing lseg
Date: Tue, 16 Dec 2014 11:01:42 -0800
Message-Id: <1418756513-95187-40-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Otherwise we'll lose error tracking information when
encoding layoutreturn.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/pnfs.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e123cfc..35465cb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -355,7 +355,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
 		return false;
 
 	list_for_each_entry(s, &lo->plh_segs, pls_list)
-		if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
+		if (s != lseg && test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
 			return false;
 
 	*stateid = lo->plh_stateid;
@@ -386,15 +386,22 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 		enum pnfs_iomode iomode;
 
 		pnfs_get_layout_hdr(lo);
-		pnfs_layout_remove_lseg(lo, lseg);
 		need_return = pnfs_layout_need_return(lo, lseg,
 						      &stateid, &iomode);
-		spin_unlock(&inode->i_lock);
-		pnfs_free_lseg(lseg);
-		if (need_return)
+		if (need_return) {
+			spin_unlock(&inode->i_lock);
+			/* hdr reference dropped in nfs4_layoutreturn_release */
 			pnfs_send_layoutreturn(lo, stateid, iomode);
-		else
+			spin_lock(&inode->i_lock);
+			pnfs_layout_remove_lseg(lo, lseg);
+			spin_unlock(&inode->i_lock);
+			pnfs_free_lseg(lseg);
+		} else {
+			pnfs_layout_remove_lseg(lo, lseg);
+			spin_unlock(&inode->i_lock);
+			pnfs_free_lseg(lseg);
 			pnfs_put_layout_hdr(lo);
+		}
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
-- 
1.9.3

