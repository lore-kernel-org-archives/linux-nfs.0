Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:57535 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbaG3M2U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:20 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so1175458qac.33
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 25/37] nfsd: Remove nfs4_lock_state(): nfsd4_test_stateid/nfsd4_free_stateid
Date: Wed, 30 Jul 2014 08:27:26 -0400
Message-Id: <1406723258-8512-26-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9013a30874e3..cd9da9891039 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4528,11 +4528,9 @@ nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd4_test_stateid_id *stateid;
 	struct nfs4_client *cl = cstate->session->se_client;
 
-	nfs4_lock_state();
 	list_for_each_entry(stateid, &test_stateid->ts_stateid_list, ts_id_list)
 		stateid->ts_id_status =
 			nfsd4_validate_stateid(cl, &stateid->ts_id_stateid);
-	nfs4_unlock_state();
 
 	return nfs_ok;
 }
@@ -4548,7 +4546,6 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
-	nfs4_lock_state();
 	spin_lock(&cl->cl_lock);
 	s = find_stateid_locked(cl, stateid);
 	if (!s)
@@ -4589,7 +4586,6 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out_unlock:
 	spin_unlock(&cl->cl_lock);
 out:
-	nfs4_unlock_state();
 	return ret;
 }
 
-- 
1.9.3

