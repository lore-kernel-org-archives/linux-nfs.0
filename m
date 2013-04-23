Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61376 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997Ab3DWS6J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:58:09 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFSv4: Don't recheck permissions on open in case of recovery cached open
Date: Tue, 23 Apr 2013 14:58:03 -0400
Message-Id: <1366743483-59247-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1366743483-59247-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1366743483-59247-1-git-send-email-Trond.Myklebust@netapp.com>
 <1366743483-59247-2-git-send-email-Trond.Myklebust@netapp.com>
 <1366743483-59247-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we already checked the user access permissions on the original open,
then don't bother checking again on recovery. Doing so can cause a
deadlock with NFSv4.1, since the may_open() operation is not privileged.
Furthermore, we can't report an access permission failure here anyway.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ea50807..e18b3b4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -769,6 +769,7 @@ struct nfs4_opendata {
 	struct iattr attrs;
 	unsigned long timestamp;
 	unsigned int rpc_done : 1;
+	unsigned int is_recover : 1;
 	int rpc_status;
 	int cancelled;
 };
@@ -1101,9 +1102,11 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		/* Save the delegation */
 		nfs4_stateid_copy(&stateid, &delegation->stateid);
 		rcu_read_unlock();
-		ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
-		if (ret != 0)
-			goto out;
+		if (!opendata->is_recover) {
+			ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
+			if (ret != 0)
+				goto out;
+		}
 		ret = -EAGAIN;
 
 		/* Try to update the stateid using the delegation */
@@ -1670,8 +1673,11 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	data->rpc_done = 0;
 	data->rpc_status = 0;
 	data->cancelled = 0;
-	if (isrecover)
+	data->is_recover = 0;
+	if (isrecover) {
 		nfs4_set_sequence_privileged(&o_arg->seq_args);
+		data->is_recover = 1;
+	}
 	task = rpc_run_task(&task_setup_data);
         if (IS_ERR(task))
                 return PTR_ERR(task);
-- 
1.8.1.4

