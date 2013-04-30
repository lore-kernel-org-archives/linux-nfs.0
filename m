Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50661 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933682Ab3D3Vpr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 17:45:47 -0400
Date: Tue, 30 Apr 2013 17:45:46 -0400
To: linux-nfs@vger.kernel.org
Cc: Frank S Filz <ffilz@us.ibm.com>
Subject: [PATCH] nfsd4: don't remap EISDIR errors in rename
Message-ID: <20130430214546.GA30768@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We're going out of our way here to remap an error to make rfc 3530
happy--but the rfc itself (nor rfc 1813, which has similar language)
gives no justification.  And disagrees with local filesystem behavior,
with Linux and posix man pages, and knfsd's implemented behavior for v2
and v3.

And the documented behavior seems better, in that it gives a little more
information--you could implement the 3530 behavior using the posix
behavior, but not the other way around.

Also, the Linux client makes no attempt to remap this error in the v4
case, so it can end up just returning EEXIST to the application in a
case where it should return EISDIR.

So honestly I think the rfc's are just buggy here--or in any case it
doesn't see worth the trouble to remap this error.

Reported-by: Frank S Filz <ffilz@us.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5dee811..8ae5abf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -813,21 +813,11 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfsd_rename(rqstp, &cstate->save_fh, rename->rn_sname,
 			     rename->rn_snamelen, &cstate->current_fh,
 			     rename->rn_tname, rename->rn_tnamelen);
-
-	/* the underlying filesystem returns different error's than required
-	 * by NFSv4. both save_fh and current_fh have been verified.. */
-	if (status == nfserr_isdir)
-		status = nfserr_exist;
-	else if ((status == nfserr_notdir) &&
-                  (S_ISDIR(cstate->save_fh.fh_dentry->d_inode->i_mode) &&
-                   S_ISDIR(cstate->current_fh.fh_dentry->d_inode->i_mode)))
-		status = nfserr_exist;
-
-	if (!status) {
-		set_change_info(&rename->rn_sinfo, &cstate->current_fh);
-		set_change_info(&rename->rn_tinfo, &cstate->save_fh);
-	}
-	return status;
+	if (status)
+		return status;
+	set_change_info(&rename->rn_sinfo, &cstate->current_fh);
+	set_change_info(&rename->rn_tinfo, &cstate->save_fh);
+	return nfs_ok;
 }
 
 static __be32
-- 
1.7.9.5

