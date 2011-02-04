Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914Ab1BDVeR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:17 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@citi.umich.edu>,
        Boaz Harrosh <bharrosh@panasas.com>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 04/40] pnfs_submit: update state renewal for data servers
Date: Fri,  4 Feb 2011 16:33:26 -0500
Message-Id: <1296855242-2592-5-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-4-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4renewd.c |    2 +-
 fs/nfs/nfs4state.c  |    5 +++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 402143d..c8dbbeb 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -65,7 +65,7 @@ nfs4_renew_state(struct work_struct *work)
 	dprintk("%s: start\n", __func__);
 
 	rcu_read_lock();
-	if (list_empty(&clp->cl_superblocks)) {
+	if (list_empty(&clp->cl_superblocks) && !is_ds_only_client(clp)) {
 		rcu_read_unlock();
 		goto out;
 	}
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e6742b5..49433aa 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -153,6 +153,11 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
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
1.6.6

