Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:37066 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbaG3M2W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:22 -0400
Received: by mail-qa0-f52.google.com with SMTP id j15so1156242qaq.39
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 26/37] nfsd: Remove nfs4_lock_state(): nfsd4_release_lockowner
Date: Wed, 30 Jul 2014 08:27:27 -0400
Message-Id: <1406723258-8512-27-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cd9da9891039..4f04a4a776cd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5573,11 +5573,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
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
@@ -5594,7 +5592,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			if (check_for_locks(stp->st_stid.sc_file, lo)) {
 				status = nfserr_locks_held;
 				spin_unlock(&clp->cl_lock);
-				goto out;
+				return status;
 			}
 		}
 
@@ -5604,8 +5602,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	spin_unlock(&clp->cl_lock);
 	if (lo)
 		release_lockowner(lo);
-out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

