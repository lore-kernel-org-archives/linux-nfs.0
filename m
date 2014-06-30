Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:56255 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498AbaF3PzX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:23 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so6543079qac.39
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:23 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 110/114] nfsd: Remove nfs4_lock_state(): reclaim_complete()
Date: Mon, 30 Jun 2014 11:54:57 -0400
Message-Id: <1404143701-24740-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f074d1b2d8ce..740f4ea47d48 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2849,7 +2849,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		 return nfs_ok;
 	}
 
-	nfs4_lock_state();
 	status = nfserr_complete_already;
 	if (test_and_set_bit(NFSD4_CLIENT_RECLAIM_COMPLETE,
 			     &cstate->session->se_client->cl_flags))
@@ -2869,7 +2868,6 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	status = nfs_ok;
 	nfsd4_client_record_create(cstate->session->se_client);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.3

