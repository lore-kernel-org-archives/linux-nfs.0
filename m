Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:61481 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751052AbeEIMDW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2018 08:03:22 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org, jlayton@kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v2] nfsd: fix error handling in nfs4_set_delegation()
Date: Wed,  9 May 2018 08:02:49 -0400
Message-Id: <20180509120249.62022-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed a memory corruption crash in nfsd in
4.17-rc1. This patch corrects the issue.

Fix to return error if the delegation couldn't be hashed or there was
a recall in progress. Use the existing error path instead of
destroy_unhashed_delegation() for readability. Set the fields of the
delegation to indicate that it does not need to be recalled.

Signed-off-by: Andrew Elble <aweits@rit.edu>
Fixes: 353601e7d323c ("nfsd: create a separate lease for each delegation")
---
v2: typo in changelog, set delegation recall-suppression
 fs/nfsd/nfs4state.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 71b87738c015..20463944cd61 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4372,12 +4372,26 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
 		status = -EAGAIN;
 	else
 		status = hash_delegation_locked(dp, fp);
+	/*
+	 * This delegation is doomed, tell the recall logic
+	 * that it's being destroyed here.
+	 */
+
+	if (status) {
+		dp->dl_time++;
+		list_del_init(&dp->dl_recall_lru);
+		dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
+	}
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
 
 	if (status)
-		destroy_unhashed_deleg(dp);
+		goto out_unlock;
+
 	return dp;
+
+out_unlock:
+	vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, (void **)&dp);
 out_clnt_odstate:
 	put_clnt_odstate(dp->dl_clnt_odstate);
 out_stid:
-- 
1.8.3.1

