Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52094 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754283Ab0HMVcb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:31 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 31/50] pnfs_submit: update state renewal for data servers
Date: Fri, 13 Aug 2010 17:31:43 -0400
Message-Id: <1281735122-1496-32-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-31-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4renewd.c |    2 +-
 fs/nfs/nfs4state.c  |    5 +++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 72b6c58..b57f41f 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -64,7 +64,7 @@ nfs4_renew_state(struct work_struct *work)
 	ops = clp->cl_mvops->state_renewal_ops;
 	dprintk("%s: start\n", __func__);
 	/* Are there any active superblocks? */
-	if (list_empty(&clp->cl_superblocks))
+	if (list_empty(&clp->cl_superblocks) && !is_ds_only_client(clp))
 		goto out;
 	spin_lock(&clp->cl_lock);
 	lease = clp->cl_lease_time;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a674452..18284bd 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -129,6 +129,11 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
 	int status;
 	struct nfs_fsinfo fsinfo;
 
+	if (is_ds_only_client(clp)) {
+		nfs4_schedule_state_renewal(clp);
+		return 0;
+	}
+
 	status = nfs4_proc_get_lease_time(clp, &fsinfo);
 	if (status == 0) {
 		/* Update lease time and schedule renewal */
-- 
1.6.2.5

