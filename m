Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52654 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880Ab1ADDHD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 22:07:03 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd4: eliminate lease delete callback
Date: Mon,  3 Jan 2011 22:06:56 -0500
Message-Id: <1294110419-3105-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1294110419-3105-1-git-send-email-bfields@redhat.com>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

nfsd controls the lifetime of the lease, not the lock code, so there's
no need for this callback on lease destruction.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

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
-- 
1.7.1

