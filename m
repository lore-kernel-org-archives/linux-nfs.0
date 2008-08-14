From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfs: remove an obsolete nfs_flock comment
Date: Thu, 14 Aug 2008 18:32:55 -0400
Message-ID: <20080814223255.GO23859@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50621 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbYHNWdB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 18:33:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We *do* now allow bsd flocks over nfs.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/file.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7846065..6061617 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -699,13 +699,6 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
 			filp->f_path.dentry->d_name.name,
 			fl->fl_type, fl->fl_flags);
 
-	/*
-	 * No BSD flocks over NFS allowed.
-	 * Note: we could try to fake a POSIX lock request here by
-	 * using ((u32) filp | 0x80000000) or some such as the pid.
-	 * Not sure whether that would be unique, though, or whether
-	 * that would break in other places.
-	 */
 	if (!(fl->fl_flags & FL_FLOCK))
 		return -ENOLCK;
 
-- 
1.5.5.rc1

