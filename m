Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:49944 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1728459AbeJEUiV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Oct 2018 16:38:21 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org, jlayton@kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] nfsd: correctly decrement odstate refcount in error path
Date: Fri,  5 Oct 2018 09:32:08 -0400
Message-Id: <20181005133208.72315-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

alloc_init_deleg() both allocates an nfs4_delegation, and
bumps the refcount on odstate. So after this point, we need to
put_clnt_odstate() and nfs4_put_stid() to not leave the odstate
refcount inappropriately bumped.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7484f04e09a2..9067bff1233d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4365,7 +4365,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
 
 	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
 	if (!fl)
-		goto out_stid;
+		goto out_clnt_odstate;
 
 	status = vfs_setlease(fp->fi_deleg_file, fl->fl_type, &fl, NULL);
 	if (fl)
@@ -4400,7 +4400,6 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
 	vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, (void **)&dp);
 out_clnt_odstate:
 	put_clnt_odstate(dp->dl_clnt_odstate);
-out_stid:
 	nfs4_put_stid(&dp->dl_stid);
 out_delegees:
 	put_deleg_file(fp);
-- 
1.8.3.1
