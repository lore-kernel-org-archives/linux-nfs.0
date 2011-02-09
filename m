Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46278 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094Ab1BIEz5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 23:55:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/6] nfsd4: fix leak on allocation error
Date: Tue,  8 Feb 2011 23:55:48 -0500
Message-Id: <1297227351-15365-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1297227351-15365-1-git-send-email-bfields@redhat.com>
References: <1297227351-15365-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Also share some common exit code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a47aedd..b59b066 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2700,14 +2700,12 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 	}
 
 	dp = alloc_init_deleg(sop->so_client, stp, fh, flag);
-	if (dp == NULL) {
-		flag = NFS4_OPEN_DELEGATE_NONE;
-		goto out;
-	}
+	if (dp == NULL)
+		goto out_no_deleg;
 	status = -ENOMEM;
 	fl = nfs4_alloc_init_lease(dp, flag);
 	if (!fl)
-		goto out;
+		goto out_free;
 	/* vfs_setlease checks to see if delegation should be handed out.
 	 * the lock_manager callback fl_change is used
 	 */
@@ -2715,9 +2713,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
 		dp->dl_flock = NULL;
 		locks_free_lock(fl);
-		unhash_delegation(dp);
-		flag = NFS4_OPEN_DELEGATE_NONE;
-		goto out;
+		goto out_free;
 	}
 
 	memcpy(&open->op_delegate_stateid, &dp->dl_stateid, sizeof(dp->dl_stateid));
@@ -2730,6 +2726,12 @@ out:
 			&& open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
 		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
 	open->op_delegate_type = flag;
+	return;
+out_free:
+	unhash_delegation(dp);
+out_no_deleg:
+	flag = NFS4_OPEN_DELEGATE_NONE;
+	goto out;
 }
 
 /*
-- 
1.7.1

