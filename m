Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:51644 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755493AbaF3PzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:55:13 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so2145017qge.39
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:55:11 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 102/114] nfsd: Remove nfs4_lock_state(): nfsd4_test_stateid/nfsd4_free_stateid
Date: Mon, 30 Jun 2014 11:54:49 -0400
Message-Id: <1404143701-24740-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2ba896fb8d31..34aba2ae6911 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4495,11 +4495,9 @@ nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd4_test_stateid_id *stateid;
 	struct nfs4_client *cl = cstate->session->se_client;
 
-	nfs4_lock_state();
 	list_for_each_entry(stateid, &test_stateid->ts_stateid_list, ts_id_list)
 		stateid->ts_id_status =
 			nfsd4_validate_stateid(cl, &stateid->ts_id_stateid);
-	nfs4_unlock_state();
 
 	return nfs_ok;
 }
@@ -4515,7 +4513,6 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
-	nfs4_lock_state();
 	spin_lock(&cl->cl_lock);
 	s = find_stateid_locked(cl, stateid);
 	if (!s)
@@ -4552,7 +4549,6 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out_unlock:
 	spin_unlock(&cl->cl_lock);
 out:
-	nfs4_unlock_state();
 	return ret;
 }
 
-- 
1.9.3

