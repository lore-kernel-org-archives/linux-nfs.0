Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:48385 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaGHSGf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:35 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so5398422qge.39
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:35 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 089/100] nfsd: Remove nfs4_lock_state(): nfsd4_release_lockowner
Date: Tue,  8 Jul 2014 14:04:17 -0400
Message-Id: <1404842668-22521-90-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2acae21e67d1..4445925c4c13 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5556,11 +5556,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);
 
-	nfs4_lock_state();
-
 	status = lookup_clientid(clid, cstate, nn);
 	if (status)
-		goto out;
+		return status;
 
 	clp = cstate->clp;
 	/* Find the matching lock stateowner */
@@ -5577,7 +5575,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			if (check_for_locks(stp->st_stid.sc_file, lo)) {
 				status = nfserr_locks_held;
 				spin_unlock(&clp->cl_lock);
-				goto out;
+				return status;
 			}
 		}
 
@@ -5587,8 +5585,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	spin_unlock(&clp->cl_lock);
 	if (lo)
 		release_lockowner(lo);
-out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

