Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33071 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283Ab1ADSSY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 13:18:24 -0500
Date: Tue, 4 Jan 2011 13:18:16 -0500
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/4] locks: eliminate fl_mylease callback
Message-ID: <20110104181815.GB2308@fieldses.org>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
 <1294110419-3105-4-git-send-email-bfields@redhat.com>
 <20110104060723.GA15158@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110104060723.GA15158@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 01:07:23AM -0500, Christoph Hellwig wrote:
> On Mon, Jan 03, 2011 at 10:06:58PM -0500, J. Bruce Fields wrote:
> > The nfs server only supports read delegations for now, so we don't care
> > how conflicts are determined.  All we care is that unlocks are
> > recognized as matching the leases they are meant to remove.  After the
> > last patch, a comparison of struct files will work for that purpose.  So
> > we no longer need this callback.
> 
> Please also update Documentation/filesystems/Locking for method
> removals.

Whoops, thanks for the reminder.

Looks like we never added fl_mylease?

That leaves the fl_release_private patch, updated as follows.

--b.

commit 3d801116bb23a1f446627ce1976950c7a126541e
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sat Oct 30 17:41:26 2010 -0400

    nfsd4: eliminate lease delete callback
    
    nfsd controls the lifetime of the lease, not the lock code, so there's
    no need for this callback on lease destruction.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index b6426f1..075be12 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -327,14 +327,12 @@ fl_release_private:	yes	yes
 prototypes:
 	int (*fl_compare_owner)(struct file_lock *, struct file_lock *);
 	void (*fl_notify)(struct file_lock *);  /* unblock callback */
-	void (*fl_release_private)(struct file_lock *);
 	void (*fl_break)(struct file_lock *); /* break_lease callback */
 
 locking rules:
 			BKL	may block
 fl_compare_owner:	yes	no
 fl_notify:		yes	no
-fl_release_private:	yes	yes
 fl_break:		yes	no
 
 	Currently only NFSD and NLM provide instances of this class. None of the
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b82e368..2e44ad2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2296,23 +2296,6 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 }
 
 /*
- * The file_lock is being reapd.
- *
- * Called by locks_free_lock() with lock_flocks() held.
- */
-static
-void nfsd_release_deleg_cb(struct file_lock *fl)
-{
-	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
-
-	dprintk("NFSD nfsd_release_deleg_cb: fl %p dp %p dl_count %d\n", fl,dp, atomic_read(&dp->dl_count));
-
-	if (!(fl->fl_flags & FL_LEASE) || !dp)
-		return;
-	dp->dl_flock = NULL;
-}
-
-/*
  * Called from setlease() with lock_flocks() held
  */
 static
@@ -2341,7 +2324,6 @@ int nfsd_change_deleg_cb(struct file_lock **onlist, int arg)
 
 static const struct lock_manager_operations nfsd_lease_mng_ops = {
 	.fl_break = nfsd_break_deleg_cb,
-	.fl_release_private = nfsd_release_deleg_cb,
 	.fl_mylease = nfsd_same_client_deleg_cb,
 	.fl_change = nfsd_change_deleg_cb,
 };
