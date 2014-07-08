Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:60947 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433AbaGHSGo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:44 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so5604354qcy.18
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:44 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 096/100] nfsd: Remove nfs4_lock_state(): reclaim_complete()
Date: Tue,  8 Jul 2014 14:04:24 -0400
Message-Id: <1404842668-22521-97-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d91e5d40e411..63db4213a5ce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2882,7 +2882,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		 return nfs_ok;
 	}
 
-	nfs4_lock_state();
 	status = nfserr_complete_already;
 	if (test_and_set_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
 			     &cstate->session->se_client->cl_flags))
@@ -2902,7 +2901,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	status = nfs_ok;
 	nfsd4_client_record_create(cstate->session->se_client);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

