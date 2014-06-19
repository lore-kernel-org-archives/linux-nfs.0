Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:34290 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOxL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:11 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so2274996qcr.16
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:10 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 093/104] NFSd: Remove nfs4_lock_state(): nfsd4_release_lockowner
Date: Thu, 19 Jun 2014 10:50:39 -0400
Message-Id: <1403189450-18729-94-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6aba06ec5dfc..254ae3e7f8b6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5423,11 +5423,9 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
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
@@ -5468,7 +5466,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 out:
 	if (sop)
 		nfs4_put_stateowner(sop);
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

