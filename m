Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577Ab2IUUw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:52:56 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 22/26] NFSv4.1: Remove unused 'default allocation' for pnfs_alloc_layout_hdr()
Date: Fri, 21 Sep 2012 16:50:17 -0400
Message-Id: <1348260621-10294-22-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-21-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-13-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-14-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-15-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-16-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-17-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-18-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-19-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-20-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-21-git-send-email-Trond.Myklebust@netapp.com>
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

