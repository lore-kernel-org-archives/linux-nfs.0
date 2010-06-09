Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42945 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758061Ab0FITMt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jun 2010 15:12:49 -0400
Date: Wed, 9 Jun 2010 15:12:47 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd bugfixes for 2.6.35
Message-ID: <20100609191246.GA12134@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These two nfsd bugfixes are suitable for 2.6.35:

  git://linux-nfs.org/~bfields/linux.git for-2.6.35

Christoph Hellwig (1):
      nfsd: nfsd_setattr needs to call commit_metadata

J. Bruce Fields (2):
      nfsd4: shut down callback queue outside state lock
      Merge branch 'for-2.6.34-incoming' into for-2.6.35-incoming

commit 44b56603c4c476b845a824cff6fe905c6268b2a1
Merge: c3935e3 b160fda
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jun 8 20:05:18 2010 -0400

    Merge branch 'for-2.6.34-incoming' into for-2.6.35-incoming

commit c3935e30495869dd611e1cd62253c94ebc7c6c04
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Jun 4 16:42:08 2010 -0400

    nfsd4: shut down callback queue outside state lock
    
    This reportedly causes a lockdep warning on nfsd shutdown.  That looks
    like a false positive to me, but there's no reason why this needs the
    state lock anyway.
    
    Reported-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 12f7109..4a27347 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4122,8 +4122,8 @@ nfs4_state_shutdown(void)
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
-	nfsd4_destroy_callback_queue();
 	nfs4_unlock_state();
+	nfsd4_destroy_callback_queue();
 }
 
 /*

commit b160fdabe93a8a53094f90f02bf4dcb500782aab
Author: Christoph Hellwig <hch@lst.de>
Date:   Tue Jun 1 21:59:18 2010 +0200

    nfsd: nfsd_setattr needs to call commit_metadata
    
    The conversion of write_inode_now calls to commit_metadata in commit
    f501912a35c02eadc55ca9396ece55fe36f785d0 missed out the call in nfsd_setattr.
    
    But without this conversion we can't guarantee that a SETATTR request
    has actually been commited to disk with XFS, which causes a regression
    from 2.6.32 (only for NFSv2, but anyway).
    
    Signed-off-by: Christoph Hellwig <hch@lst.de>
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6dd5f19..3440dd8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -443,8 +443,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (size_change)
 		put_write_access(inode);
 	if (!err)
-		if (EX_ISSYNC(fhp->fh_export))
-			write_inode_now(inode, 1);
+		commit_metadata(fhp);
 out:
 	return err;
 
