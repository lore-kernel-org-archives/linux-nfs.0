Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47585 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbaELBXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 21:23:44 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 12 May 2014 11:22:47 +1000
Subject: [PATCH 2/2] nfsd: Only set PF_LESS_THROTTLE when really needed.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140512012247.20840.45267.stgit@notabene.brown>
In-Reply-To: <20140512012120.20840.68685.stgit@notabene.brown>
References: <20140512012120.20840.68685.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
and live-locks while writing to the page cache in a loop-back
NFS mount situation.

It therefore makes sense to *only* set PF_LESS_THROTTLE in this
situation.
We now know when a request came from the local-host so it could be a
loop-back mount.  We already know when we are handling write requests,
and when we are doing anything else.

So combine those two to allow nfsd to still be throttled (like any
other process) in every situation except when it is known to be
problematic.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfssvc.c |    6 ------
 fs/nfsd/vfs.c    |   12 ++++++++++++
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9a4a5f9e7468..1879e43f2868 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -591,12 +591,6 @@ nfsd(void *vrqstp)
 	nfsdstats.th_cnt++;
 	mutex_unlock(&nfsd_mutex);
 
-	/*
-	 * We want less throttling in balance_dirty_pages() so that nfs to
-	 * localhost doesn't cause nfsd to lock up due to all the client's
-	 * dirty pages.
-	 */
-	current->flags |= PF_LESS_THROTTLE;
 	set_freezable();
 
 	/*
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 16f0673a423c..b05d21e93d9a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -922,6 +922,16 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	int			stable = *stablep;
 	int			use_wgather;
 	loff_t			pos = offset;
+	unsigned int		pflags = current->flags;
+
+	if (rqstp->rq_local)
+		/*
+		 * We want less throttling in balance_dirty_pages()
+		 * and shrink_inactive_list() so that nfs to
+		 * localhost doesn't cause nfsd to lock up due to all
+		 * the client's dirty pages or its congested queue.
+		 */
+		current->flags |= PF_LESS_THROTTLE;
 
 	dentry = file->f_path.dentry;
 	inode = dentry->d_inode;
@@ -959,6 +969,8 @@ out_nfserr:
 		err = 0;
 	else
 		err = nfserrno(host_err);
+	if (rqstp->rq_local)
+		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
 	return err;
 }
 


