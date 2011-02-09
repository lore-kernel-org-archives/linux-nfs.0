Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46280 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126Ab1BIEz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 23:55:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/6] nfsd4: split lease setting into separate function
Date: Tue,  8 Feb 2011 23:55:49 -0500
Message-Id: <1297227351-15365-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1297227351-15365-1-git-send-email-bfields@redhat.com>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Splitting some code into a separate function which we'll be adding some
more to.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b59b066..77e94f0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2660,6 +2660,23 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int f
 	return fl;
 }
 
+static int nfs4_setlease(struct nfs4_delegation *dp, int flag)
+{
+	struct file_lock *fl;
+	int status;
+
+	fl = nfs4_alloc_init_lease(dp, flag);
+	if (!fl)
+		return -ENOMEM;
+	status = vfs_setlease(dp->dl_vfs_file, fl->fl_type, &fl);
+	if (status) {
+		dp->dl_flock = NULL;
+		locks_free_lock(fl);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
 /*
  * Attempt to hand out a delegation.
  */
@@ -2669,7 +2686,6 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
 	int cb_up;
-	struct file_lock *fl;
 	int status, flag = 0;
 
 	cb_up = nfsd4_cb_channel_good(sop->so_client);
@@ -2702,19 +2718,9 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	dp = alloc_init_deleg(sop->so_client, stp, fh, flag);
 	if (dp == NULL)
 		goto out_no_deleg;
-	status = -ENOMEM;
-	fl = nfs4_alloc_init_lease(dp, flag);
-	if (!fl)
-		goto out_free;
-	/* vfs_setlease checks to see if delegation should be handed out.
-	 * the lock_manager callback fl_change is used
-	 */
-	if ((status = vfs_setlease(fl->fl_file, fl->fl_type, &fl))) {
-		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
-		dp->dl_flock = NULL;
-		locks_free_lock(fl);
+	status = nfs4_setlease(dp, flag);
+	if (status)
 		goto out_free;
-	}
 
 	memcpy(&open->op_delegate_stateid, &dp->dl_stateid, sizeof(dp->dl_stateid));
 
-- 
1.7.1

