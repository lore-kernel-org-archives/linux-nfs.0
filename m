From: andros@netapp.com
Subject: [PATCH 2/2] SQUASHME pnfs-submit file layout free_layout init_only
Date: Fri,  9 Jul 2010 12:39:31 -0400
Message-ID: <1278693571-3328-3-git-send-email-andros@netapp.com>
References: <1278693571-3328-1-git-send-email-andros@netapp.com>
 <1278693571-3328-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63483 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757926Ab0GIQjl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jul 2010 12:39:41 -0400
In-Reply-To: <1278693571-3328-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Implement the new free_layout layoutdriver io operation init_only boolean.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b49ccf4..e1b0d6c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -314,9 +314,19 @@ filelayout_alloc_layout(struct inode *inode)
 /* Free a filelayout layout structure
  */
 static void
-filelayout_free_layout(struct pnfs_layout_type *lo)
+filelayout_free_layout(struct pnfs_layout_type *lo, bool init_only)
 {
-	dprintk("NFS_FILELAYOUT: freeing layout\n");
+	if (init_only) {
+		struct nfs4_filelayout *flp = FILE_LO(lo);
+
+		dprintk("%s re-intializing layout\n", __func__);
+		flp->uncommitted_write = 0;
+		flp->last_commit_size = 0;
+		flp->layout_id = 0;
+		flp->stripe_unit = 0;
+		return;
+	}
+	dprintk("%s freeing layout\n", __func__);
 	kfree(lo);
 }
 
-- 
1.6.6

