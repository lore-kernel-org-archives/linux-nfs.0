Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46275 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979Ab1BIEz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 23:55:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/6] nfsd4: split up nfsd_break_deleg_cb
Date: Tue,  8 Feb 2011 23:55:46 -0500
Message-Id: <1297227351-15365-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1297227351-15365-1-git-send-email-bfields@redhat.com>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We'll be adding some more code here soon.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   35 +++++++++++++++++------------------
 1 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d98d021..b5bdc33 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2329,23 +2329,8 @@ nfs4_file_downgrade(struct nfs4_file *fp, unsigned int share_access)
 		nfs4_file_put_access(fp, O_RDONLY);
 }
 
-/*
- * Spawn a thread to perform a recall on the delegation represented
- * by the lease (file_lock)
- *
- * Called from break_lease() with lock_flocks() held.
- * Note: we assume break_lease will only call this *once* for any given
- * lease.
- */
-static
-void nfsd_break_deleg_cb(struct file_lock *fl)
+static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 {
-	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
-
-	dprintk("NFSD nfsd_break_deleg_cb: dp %p fl %p\n",dp,fl);
-	if (!dp)
-		return;
-
 	/* We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
 	 * callback (and since the lease code is serialized by the kernel
@@ -2360,15 +2345,29 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 	/* only place dl_time is set. protected by lock_flocks*/
 	dp->dl_time = get_seconds();
 
+	nfsd4_cb_recall(dp);
+}
+
+/*
+ * Called from break_lease() with lock_flocks() held.
+ * Note: we assume break_lease will only call this *once* for any given
+ * lease.
+ */
+static
+void nfsd_break_deleg_cb(struct file_lock *fl)
+{
+	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
+
+	BUG_ON(!dp);
 	/*
 	 * We don't want the locks code to timeout the lease for us;
 	 * we'll remove it ourself if the delegation isn't returned
-	 * in time.
+	 * in time:
 	 */
 	fl->fl_break_time = 0;
 
+	nfsd_break_one_deleg(dp);
 	dp->dl_file->fi_had_conflict = true;
-	nfsd4_cb_recall(dp);
 }
 
 static
-- 
1.7.1

