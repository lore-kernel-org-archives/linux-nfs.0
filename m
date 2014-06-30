Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:35642 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952AbaF3PzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:13 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so7367253qcy.29
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 103/114] nfsd: Remove nfs4_lock_state(): nfsd4_release_lockowner
Date: Mon, 30 Jun 2014 11:54:50 -0400
Message-Id: <1404143701-24740-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 34aba2ae6911..99e51d4e097e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5518,11 +5518,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
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
@@ -5539,7 +5537,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			if (check_for_locks(stp->st_stid.sc_file, lo)) {
 				status = nfserr_locks_held;
 				spin_unlock(&clp->cl_lock);
-				goto out;
+				return status;
 			}
 		}
 
@@ -5549,8 +5547,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	spin_unlock(&clp->cl_lock);
 	if (lo)
 		release_lockowner(lo);
-out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

