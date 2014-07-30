Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36098 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbaG3M23 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:29 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so1269577qge.39
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:28 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 31/37] nfsd: Remove nfs4_lock_state(): exchange_id, create/destroy_session()
Date: Wed, 30 Jul 2014 08:27:32 -0400
Message-Id: <1406723258-8512-32-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Also destroy_clientid and bind_conn_to_session.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 02caef874d67..3b7fceed0a0a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2205,7 +2205,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_jukebox;
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
 	if (conf) {
@@ -2284,7 +2283,6 @@ out_copy:
 
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		expire_client(new);
 	if (unconf)
@@ -2458,7 +2456,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	if (!conn)
 		goto out_free_session;
 
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
 	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
@@ -2528,13 +2525,11 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -2590,7 +2585,6 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	session = find_in_sessionid_hashtbl(&bcts->sessionid, net, &status);
 	spin_unlock(&nn->client_lock);
@@ -2611,7 +2605,6 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 out:
 	nfsd4_put_session(session);
 out_no_session:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -2633,7 +2626,6 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	struct net *net = SVC_NET(r);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	nfs4_lock_state();
 	status = nfserr_not_only_op;
 	if (nfsd4_compound_in_session(cstate->session, &sessionid->sessionid)) {
 		if (!nfsd4_last_compound_op(r))
@@ -2663,7 +2655,6 @@ out_put_session:
 out_client_lock:
 	spin_unlock(&nn->client_lock);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -2866,7 +2857,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	__be32 status = 0;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&dc->clientid, true, nn);
 	conf = find_confirmed_client(&dc->clientid, true, nn);
@@ -2895,7 +2885,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	unhash_client_locked(clp);
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (clp)
 		expire_client(clp);
 	return status;
-- 
1.9.3

