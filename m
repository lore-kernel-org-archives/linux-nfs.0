Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42911 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594Ab0J3Vb2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Oct 2010 17:31:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: initialize delegation pointer to lease
Date: Sat, 30 Oct 2010 17:31:16 -0400
Message-Id: <1288474276-14288-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20101030212500.GE480@fieldses.org>
References: <20101030212500.GE480@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The NFSv4 server was initializing the dp->dl_flock pointer by the
somewhat ridiculous method of a locks_copy_lock callback.

Now that setlease uses the passed-in lock instead of doing a copy,
dl_flock no longer gets set, resulting in the lock leaking on delegation
release, and later possible hangs (among other problems).

So, initialize dl_flock and get rid of the callback.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 56347e0..b7f818b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2310,22 +2310,6 @@ void nfsd_release_deleg_cb(struct file_lock *fl)
 }
 
 /*
- * Set the delegation file_lock back pointer.
- *
- * Called from setlease() with lock_kernel() held.
- */
-static
-void nfsd_copy_lock_deleg_cb(struct file_lock *new, struct file_lock *fl)
-{
-	struct nfs4_delegation *dp = (struct nfs4_delegation *)new->fl_owner;
-
-	dprintk("NFSD: nfsd_copy_lock_deleg_cb: new fl %p dp %p\n", new, dp);
-	if (!dp)
-		return;
-	dp->dl_flock = new;
-}
-
-/*
  * Called from setlease() with lock_kernel() held
  */
 static
@@ -2355,7 +2339,6 @@ int nfsd_change_deleg_cb(struct file_lock **onlist, int arg)
 static const struct lock_manager_operations nfsd_lease_mng_ops = {
 	.fl_break = nfsd_break_deleg_cb,
 	.fl_release_private = nfsd_release_deleg_cb,
-	.fl_copy_lock = nfsd_copy_lock_deleg_cb,
 	.fl_mylease = nfsd_same_client_deleg_cb,
 	.fl_change = nfsd_change_deleg_cb,
 };
@@ -2661,12 +2644,14 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	fl->fl_file = find_readable_file(stp->st_file);
 	BUG_ON(!fl->fl_file);
 	fl->fl_pid = current->tgid;
+	dp->dl_flock = fl;
 
 	/* vfs_setlease checks to see if delegation should be handed out.
 	 * the lock_manager callbacks fl_mylease and fl_change are used
 	 */
 	if ((status = vfs_setlease(fl->fl_file, fl->fl_type, &fl))) {
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
+		dp->dl_flock = NULL;
 		unhash_delegation(dp);
 		flag = NFS4_OPEN_DELEGATE_NONE;
 		goto out;
-- 
1.7.1

