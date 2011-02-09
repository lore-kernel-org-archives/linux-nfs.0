Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46282 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286Ab1BIEz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 23:55:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/6] nfsd4: add helper function for lease setup
Date: Tue,  8 Feb 2011 23:55:47 -0500
Message-Id: <1297227351-15365-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1297227351-15365-1-git-send-email-bfields@redhat.com>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   33 +++++++++++++++++++++------------
 1 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b5bdc33..a47aedd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2640,6 +2640,26 @@ static bool nfsd4_cb_channel_good(struct nfs4_client *clp)
 	return clp->cl_minorversion && clp->cl_cb_state == NFSD4_CB_UNKNOWN;
 }
 
+static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp, int flag)
+{
+	struct file_lock *fl;
+
+	fl = locks_alloc_lock();
+	if (!fl)
+		return NULL;
+	locks_init_lock(fl);
+	fl->fl_lmops = &nfsd_lease_mng_ops;
+	fl->fl_flags = FL_LEASE;
+	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
+	fl->fl_end = OFFSET_MAX;
+	fl->fl_owner = (fl_owner_t)dp;
+	fl->fl_file = dp->dl_vfs_file;
+	BUG_ON(!fl->fl_file);
+	fl->fl_pid = current->tgid;
+	dp->dl_flock = fl;
+	return fl;
+}
+
 /*
  * Attempt to hand out a delegation.
  */
@@ -2685,20 +2705,9 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 		goto out;
 	}
 	status = -ENOMEM;
-	fl = locks_alloc_lock();
+	fl = nfs4_alloc_init_lease(dp, flag);
 	if (!fl)
 		goto out;
-	locks_init_lock(fl);
-	fl->fl_lmops = &nfsd_lease_mng_ops;
-	fl->fl_flags = FL_LEASE;
-	fl->fl_type = flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK;
-	fl->fl_end = OFFSET_MAX;
-	fl->fl_owner =  (fl_owner_t)dp;
-	fl->fl_file = find_readable_file(stp->st_file);
-	BUG_ON(!fl->fl_file);
-	fl->fl_pid = current->tgid;
-	dp->dl_flock = fl;
-
 	/* vfs_setlease checks to see if delegation should be handed out.
 	 * the lock_manager callback fl_change is used
 	 */
-- 
1.7.1

