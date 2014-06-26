Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:46947 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbaFZTOd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:33 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so3139567qac.25
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 034/117] nfsd: cleanup nfs4_check_open
Date: Thu, 26 Jun 2014 15:12:14 -0400
Message-Id: <1403810017-16062-35-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename it to better describe what it does, and have it just return the
stateid instead of a __be32 (which is now always nfs_ok).

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 93d175661c8d..e75cb6da1e64 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3269,10 +3269,10 @@ out:
 	return nfs_ok;
 }
 
-static __be32
-nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_stateid **stpp)
+static struct nfs4_ol_stateid *
+nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
 {
-	struct nfs4_ol_stateid *local;
+	struct nfs4_ol_stateid *local, *ret = NULL;
 	struct nfs4_openowner *oo = open->op_openowner;
 
 	lockdep_assert_held(&fp->fi_lock);
@@ -3283,11 +3283,11 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 			continue;
 		/* remember if we have seen this open owner */
 		if (local->st_stateowner == &oo->oo_owner) {
-			*stpp = local;
+			ret = local;
 			break;
 		}
 	}
-	return nfs_ok;
+	return ret;
 }
 
 static inline int nfs4_access_to_access(u32 nfs4_access)
@@ -3623,7 +3623,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		spin_lock(&fp->fi_lock);
 		status = nfs4_file_check_deny(fp, 0, open->op_share_deny);
 		if (status == nfs_ok)
-			status = nfs4_check_open(fp, open, &stp);
+			stp = nfsd4_find_existing_open(fp, open);
 		spin_unlock(&fp->fi_lock);
 		if (status)
 			goto out;
-- 
1.9.3

