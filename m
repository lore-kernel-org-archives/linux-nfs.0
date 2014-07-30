Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:57335 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745AbaG3M2c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:32 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so1290986qgd.0
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:31 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 33/37] nfsd: Remove nfs4_lock_state(): reclaim_complete()
Date: Wed, 30 Jul 2014 08:27:34 -0400
Message-Id: <1406723258-8512-34-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a45dcd15b8f7..d98d33d0e304 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2905,7 +2905,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		 return nfs_ok;
 	}
 
-	nfs4_lock_state();
 	status = nfserr_complete_already;
 	if (test_and_set_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
 			     &cstate->session->se_client->cl_flags))
@@ -2925,7 +2924,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	status = nfs_ok;
 	nfsd4_client_record_create(cstate->session->se_client);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

