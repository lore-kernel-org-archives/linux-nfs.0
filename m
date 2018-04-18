Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:44840 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1750981AbeDRVLe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2018 17:11:34 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@redhat.com, jlayton@kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] nfsd: fix error handling in nfs4_set_delegation()
Date: Wed, 18 Apr 2018 17:04:37 -0400
Message-Id: <20180418210437.97702-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed a memory corruption crash in nfsd in
4.17-rc1. This patch corrects the issue.

Fix to return error if the delegation couldn't be hashed or there was
a recall in progress. Use the existing error path instead of
destroy_delegation() for readability.

Signed-off-by: Andrew Elble <aweits@rit.edu>
Fixes: 353601e7d323c ("nfsd: create a separate lease for each delegation")
---
 fs/nfsd/nfs4state.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 71b87738c015..449d42a0f71b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4376,8 +4376,11 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
 	spin_unlock(&state_lock);
 
 	if (status)
-		destroy_unhashed_deleg(dp);
+		goto out_unlock;
+
 	return dp;
+out_unlock:
+	vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, (void **)&dp);
 out_clnt_odstate:
 	put_clnt_odstate(dp->dl_clnt_odstate);
 out_stid:
-- 
1.8.3.1

