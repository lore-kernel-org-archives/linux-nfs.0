Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:55565 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758158Ab0KQP1S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 10:27:18 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] BKL: remove references to lock_kernel from comments
Date: Wed, 17 Nov 2010 16:26:56 +0100
Message-Id: <1290007619-5787-5-git-send-email-arnd@arndb.de>
In-Reply-To: <1290007619-5787-1-git-send-email-arnd@arndb.de>
References: <1290007619-5787-1-git-send-email-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Lock_kernel is gone from the code, so the comments
should be updated, too. nfsd now uses lock_flocks
instead of lock_kernel to protect against posix
file locks.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfsd/nfs4state.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f1e5ec6..36db9cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2254,7 +2254,7 @@ nfs4_file_downgrade(struct nfs4_file *fp, unsigned int share_access)
  * Spawn a thread to perform a recall on the delegation represented
  * by the lease (file_lock)
  *
- * Called from break_lease() with lock_kernel() held.
+ * Called from break_lease() with lock_flocks() held.
  * Note: we assume break_lease will only call this *once* for any given
  * lease.
  */
@@ -2278,7 +2278,7 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 	list_add_tail(&dp->dl_recall_lru, &del_recall_lru);
 	spin_unlock(&recall_lock);
 
-	/* only place dl_time is set. protected by lock_kernel*/
+	/* only place dl_time is set. protected by lock_flocks*/
 	dp->dl_time = get_seconds();
 
 	/*
@@ -2295,7 +2295,7 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 /*
  * The file_lock is being reapd.
  *
- * Called by locks_free_lock() with lock_kernel() held.
+ * Called by locks_free_lock() with lock_flocks() held.
  */
 static
 void nfsd_release_deleg_cb(struct file_lock *fl)
@@ -2310,7 +2310,7 @@ void nfsd_release_deleg_cb(struct file_lock *fl)
 }
 
 /*
- * Called from setlease() with lock_kernel() held
+ * Called from setlease() with lock_flocks() held
  */
 static
 int nfsd_same_client_deleg_cb(struct file_lock *onlist, struct file_lock *try)
-- 
1.7.1

