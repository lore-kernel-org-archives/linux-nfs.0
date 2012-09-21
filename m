Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59283 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217Ab2IUUxB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:53:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 23/26] squash! NFSv4.1: Remove redundant reference to the pnfs_layout_hdr
Date: Fri, 21 Sep 2012 16:50:18 -0400
Message-Id: <1348260621-10294-23-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-22-git-send-email-Trond.Myklebust@netapp.com>
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
 <1348260621-10294-22-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that pnfs_find_alloc_layout() always returns a reference
to the pnfs_layout_hdr, which will be matched by the final call to
pnfs_put_layout_hdr() in pnfs_update_layout().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 196b8bb..bdb70cc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -884,8 +884,8 @@ pnfs_find_alloc_layout(struct inode *ino,
 	if (nfsi->layout) {
 		if (test_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags))
 			return NULL;
-		else
-			return nfsi->layout;
+		pnfs_get_layout_hdr(nfsi->layout);
+		return nfsi->layout;
 	}
 	spin_unlock(&ino->i_lock);
 	new = alloc_init_layout_hdr(ino, ctx, gfp_flags);
-- 
1.7.11.4

