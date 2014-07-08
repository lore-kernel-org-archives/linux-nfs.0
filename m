Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:38194 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755415AbaGHSGe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:34 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so5543591qgd.35
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:33 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 088/100] nfsd: Remove nfs4_lock_state(): nfsd4_test_stateid/nfsd4_free_stateid
Date: Tue,  8 Jul 2014 14:04:16 -0400
Message-Id: <1404842668-22521-89-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5410b7ee2273..2acae21e67d1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4531,11 +4531,9 @@ nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd4_test_stateid_id *stateid;
 	struct nfs4_client *cl = cstate->session->se_client;
 
-	nfs4_lock_state();
 	list_for_each_entry(stateid, &test_stateid->ts_stateid_list, ts_id_list)
 		stateid->ts_id_status =
 			nfsd4_validate_stateid(cl, &stateid->ts_id_stateid);
-	nfs4_unlock_state();
 
 	return nfs_ok;
 }
@@ -4551,7 +4549,6 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
-	nfs4_lock_state();
 	spin_lock(&cl->cl_lock);
 	s = find_stateid_locked(cl, stateid);
 	if (!s)
@@ -4588,7 +4585,6 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out_unlock:
 	spin_unlock(&cl->cl_lock);
 out:
-	nfs4_unlock_state();
 	return ret;
 }
 
-- 
1.9.3

