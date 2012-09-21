Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:26053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754736Ab2IUBgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:11 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/14] NFSv4.1: Remove unused 'default allocation' for pnfs_alloc_layout_hdr()
Date: Thu, 20 Sep 2012 21:35:57 -0400
Message-Id: <1348191357-44503-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and ditto for pnfs_free_layout_hdr()

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bbdce87..196b8bb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -200,8 +200,7 @@ static struct pnfs_layout_hdr *
 pnfs_alloc_layout_hdr(struct inode *ino, gfp_t gfp_flags)
 {
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(ino)->pnfs_curr_ld;
-	return ld->alloc_layout_hdr ? ld->alloc_layout_hdr(ino, gfp_flags) :
-		kzalloc(sizeof(struct pnfs_layout_hdr), gfp_flags);
+	return ld->alloc_layout_hdr(ino, gfp_flags);
 }
 
 static void
@@ -218,7 +217,7 @@ pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
 		spin_unlock(&clp->cl_lock);
 	}
 	put_rpccred(lo->plh_lc_cred);
-	return ld->alloc_layout_hdr ? ld->free_layout_hdr(lo) : kfree(lo);
+	return ld->free_layout_hdr(lo);
 }
 
 static void
-- 
1.7.11.4

