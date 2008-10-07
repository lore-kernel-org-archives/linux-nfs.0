From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 17/30] nfs: remove an obsolete nfs_flock comment
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.78589.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754815AbYJGWco (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:44 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

We *do* now allow bsd flocks over nfs.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3ddb004..d319b49 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -702,13 +702,6 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
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
 

