From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/7] nfs: remove an obsolete nfs_flock comment
Date: Fri, 26 Sep 2008 19:35:11 -0400
Message-ID: <1222472117-9773-2-git-send-email-bfields@citi.umich.edu>
References: <1222472117-9773-1-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58542 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752749AbYIZXfU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 19:35:20 -0400
In-Reply-To: <1222472117-9773-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

