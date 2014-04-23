Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52742 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756506AbaDWDsj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2014 23:48:39 -0400
From: NeilBrown <neilb@suse.de>
To: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 23 Apr 2014 12:40:58 +1000
Subject: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-ID: <20140423024058.4725.38098.stgit@notabene.brown>
In-Reply-To: <20140423022441.4725.89693.stgit@notabene.brown>
References: <20140423022441.4725.89693.stgit@notabene.brown>
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
index 6d7be3f80356..2acd00445ad0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -913,6 +913,16 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
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
@@ -950,6 +960,8 @@ out_nfserr:
 		err = 0;
 	else
 		err = nfserrno(host_err);
+	if (rqstp->rq_local)
+		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
 	return err;
 }
 


