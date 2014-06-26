Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:62132 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbaFZTWB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:22:01 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so3534330qgf.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:22:00 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 106/117] nfsd: Remove nfs4_lock_state(): nfsd4_release_lockowner
Date: Thu, 26 Jun 2014 15:21:14 -0400
Message-Id: <1403810485-16497-23-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e5b7b8bbc609..2be356341929 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5532,11 +5532,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);
 
-	nfs4_lock_state();
-
 	status = lookup_clientid(clid, cstate, nn);
 	if (status)
-		goto out;
+		return status;
 
 	status = nfserr_locks_held;
 	INIT_LIST_HEAD(&matches);
@@ -5578,7 +5576,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 out:
 	if (sop)
 		nfs4_put_stateowner(sop);
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

