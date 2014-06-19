Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:53256 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932760AbaFSOxS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:18 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so2239599qge.11
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 098/104] NFSd: Remove nfs4_lock_state(): exchange_id, create/destroy_session()
Date: Thu, 19 Jun 2014 10:50:44 -0400
Message-Id: <1403189450-18729-99-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Also destroy_clientid and bind_conn_to_session.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0dfe24e0aa61..d91247f86d6b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2044,7 +2044,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_jukebox;
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
 	if (conf) {
@@ -2123,7 +2122,6 @@ out_copy:
 
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (new)
 		expire_client(new);
 	if (unconf)
@@ -2297,7 +2295,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	if (!conn)
 		goto out_free_session;
 
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true, nn);
 	conf = find_confirmed_client(&cr_ses->clientid, true, nn);
@@ -2367,13 +2364,11 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -2429,7 +2424,6 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	session = find_in_sessionid_hashtbl(&bcts->sessionid, net, &status);
 	spin_unlock(&nn->client_lock);
@@ -2450,7 +2444,6 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 out:
 	nfsd4_put_session(session);
 out_no_session:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -2472,7 +2465,6 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	struct net *net = SVC_NET(r);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	nfs4_lock_state();
 	status = nfserr_not_only_op;
 	if (nfsd4_compound_in_session(cstate->session, &sessionid->sessionid)) {
 		if (!nfsd4_last_compound_op(r))
@@ -2502,7 +2494,6 @@ out_put_session:
 out_client_lock:
 	spin_unlock(&nn->client_lock);
 out:
-	nfs4_unlock_state();
 	return status;
 }
 
@@ -2705,7 +2696,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	__be32 status = 0;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
-	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
 	unconf = find_unconfirmed_client(&dc->clientid, true, nn);
 	conf = find_confirmed_client(&dc->clientid, true, nn);
@@ -2734,7 +2724,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	unhash_client_locked(clp);
 out:
 	spin_unlock(&nn->client_lock);
-	nfs4_unlock_state();
 	if (clp)
 		expire_client(clp);
 	return status;
-- 
1.9.3

