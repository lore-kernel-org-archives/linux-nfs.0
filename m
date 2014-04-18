Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:53858 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445AbaDRSqz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:55 -0400
Received: by mail-ie0-f180.google.com with SMTP id as1so1907417iec.11
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 68/70] NFSd: Remove nfs4_lock_state(): exchange_id, create/destroy_session()
Date: Fri, 18 Apr 2014 14:45:02 -0400
Message-Id: <1397846704-14567-69-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-68-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-52-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-53-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-54-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-55-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-56-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-57-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-58-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-59-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-60-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-61-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-62-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-63-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-64-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-65-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-66-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-67-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-68-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also destroy_clientid and bind_conn_to_session.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 188eb4cbea95..3a0a3e8c9982 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1890,7 +1890,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_jukebox;
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
 	if (conf) {
@@ -1966,7 +1965,6 @@ out_copy:
 
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		expire_client(new);
 	if (unconf)
@@ -2140,7 +2138,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	if (!conn)
 		goto out_free_session;
 
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
 	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
@@ -2209,13 +2206,11 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	/* init connection and backchannel */
 	nfsd4_init_conn(rqstp, conn, new);
 	nfsd4_put_session(new);
-	nfs4_unlock_state();
 	if (old)
 		expire_client(old);
 	return status;
 out_free_conn:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	free_conn(conn);
 	if (old)
 		expire_client(old);
@@ -2271,7 +2266,6 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	session = find_in_sessionid_hashtbl(&bcts->sessionid, net, &status);
 	spin_unlock(&nn->client_lock);
@@ -2292,7 +2286,6 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 out:
 	nfsd4_put_session(session);
 out_no_session:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -2314,7 +2307,6 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	struct net *net = SVC_NET(r);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	nfs4_lock_state();
 	status = nfserr_not_only_op;
 	if (nfsd4_compound_in_session(cstate->session, &sessionid->sessionid)) {
 		if (!nfsd4_last_compound_op(r))
@@ -2344,7 +2336,6 @@ out_put_session:
 out_client_lock:
 	spin_unlock(&nn->client_lock);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -2532,7 +2523,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	__be32 status = 0;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&dc->clientid, true, nn);
 	conf = find_confirmed_client(&dc->clientid, true, nn);
@@ -2558,7 +2548,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	unhash_client_locked(clp);
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (clp)
 		expire_client(clp);
 	return status;
-- 
1.9.0

