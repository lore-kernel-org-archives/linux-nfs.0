Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:63983 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778AbaFSOxV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:21 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so2000994qac.4
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 100/104] NFSd: Remove nfs4_lock_state(): reclaim_complete()
Date: Thu, 19 Jun 2014 10:50:46 -0400
Message-Id: <1403189450-18729-101-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e159e316ecdb..6000da3285d7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2744,7 +2744,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		 return nfs_ok;
 	}
 
-	nfs4_lock_state();
 	status = nfserr_complete_already;
 	if (test_and_set_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
 			     &cstate->session->se_client->cl_flags))
@@ -2764,7 +2763,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	status = nfs_ok;
 	nfsd4_client_record_create(cstate->session->se_client);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

