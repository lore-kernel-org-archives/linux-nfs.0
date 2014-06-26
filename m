Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:34268 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbaFZTWK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:22:10 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so3615247qcx.13
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:22:09 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 113/117] nfsd: Remove nfs4_lock_state(): reclaim_complete()
Date: Thu, 26 Jun 2014 15:21:21 -0400
Message-Id: <1403810485-16497-30-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9d963037eaa2..ccf6bb390fbb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2856,7 +2856,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		 return nfs_ok;
 	}
 
-	nfs4_lock_state();
 	status = nfserr_complete_already;
 	if (test_and_set_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
 			     &cstate->session->se_client->cl_flags))
@@ -2876,7 +2875,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	status = nfs_ok;
 	nfsd4_client_record_create(cstate->session->se_client);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

