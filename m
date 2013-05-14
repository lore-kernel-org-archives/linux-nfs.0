Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42752 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758550Ab3ENVM4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:12:56 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd4: implement minimal SP4_MACH_CRED
Date: Tue, 14 May 2013 17:12:53 -0400
Message-Id: <1368565973-16739-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1368565973-16739-1-git-send-email-bfields@redhat.com>
References: <1368565973-16739-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Do a minimal SP4_MACH_CRED implementation suggested by Trond, ignoring
the client-provided spo_must_* arrays and just enforcing credential
checks for the minimum required operations.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   66 +++++++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs4xdr.c   |   22 +++++++++++++++++
 fs/nfsd/state.h     |    1 +
 3 files changed, 77 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 52f9e92..4e50a2d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1265,6 +1265,23 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
 }
 
+static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
+{
+	struct svc_cred *cr = &rqstp->rq_cred;
+	u32 service;
+
+	if (!cl->cl_mach_cred)
+		return true;
+	if (cl->cl_cred.cr_gss_mech != cr->cr_gss_mech)
+		return false;
+	service = gss_pseudoflavor_to_service(cr->cr_gss_mech, cr->cr_flavor);
+	if (service != RPC_AUTH_GSS_KRB5I && service != RPC_AUTH_GSS_KRB5P)
+		return false;
+	if (!cr->cr_principal)
+		return false;
+	return 0 == strcmp(cl->cl_cred.cr_principal, cr->cr_principal);
+}
+
 static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
 {
 	static u32 current_clientid = 1;
@@ -1642,16 +1659,14 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	if (exid->flags & ~EXCHGID4_FLAG_MASK_A)
 		return nfserr_inval;
 
-	/* Currently only support SP4_NONE */
 	switch (exid->spa_how) {
+	case SP4_MACH_CRED:
 	case SP4_NONE:
 		break;
 	default:				/* checked by xdr code */
 		WARN_ON_ONCE(1);
 	case SP4_SSV:
 		return nfserr_encr_alg_unsupp;
-	case SP4_MACH_CRED:
-		return nfserr_serverfault;	/* no excuse :-/ */
 	}
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
@@ -1666,6 +1681,10 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 				status = nfserr_inval;
 				goto out;
 			}
+			if (!mach_creds_match(conf, rqstp)) {
+				status = nfserr_wrong_cred;
+				goto out;
+			}
 			if (!creds_match) { /* case 9 */
 				status = nfserr_perm;
 				goto out;
@@ -1713,6 +1732,7 @@ out_new:
 		goto out;
 	}
 	new->cl_minorversion = cstate->minorversion;
+	new->cl_mach_cred = (exid->spa_how == SP4_MACH_CRED);
 
 	gen_clid(new, nn);
 	add_to_unconfirmed(new);
@@ -1877,6 +1897,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	WARN_ON_ONCE(conf && unconf);
 
 	if (conf) {
+		status = nfserr_wrong_cred;
+		if (!mach_creds_match(conf, rqstp))
+			goto out_free_conn;
 		cs_slot = &conf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status == nfserr_replay_cache) {
@@ -1893,6 +1916,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = nfserr_clid_inuse;
 			goto out_free_conn;
 		}
+		status = nfserr_wrong_cred;
+		if (!mach_creds_match(unconf, rqstp))
+			goto out_free_conn;
 		cs_slot = &unconf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status) {
@@ -1989,6 +2015,9 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	status = nfserr_badsession;
 	if (!session)
 		goto out;
+	status = nfserr_wrong_cred;
+	if (!mach_creds_match(session->se_client, rqstp))
+		goto out;
 	status = nfsd4_map_bcts_dir(&bcts->dir);
 	if (status)
 		goto out;
@@ -2031,6 +2060,9 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	status = nfserr_badsession;
 	if (!ses)
 		goto out_client_lock;
+	status = nfserr_wrong_cred;
+	if (!mach_creds_match(ses->se_client, r))
+		goto out_client_lock;
 	status = mark_session_dead_locked(ses);
 	if (status)
 		goto out_client_lock;
@@ -2061,26 +2093,31 @@ static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt, struct nfsd4_s
 	return NULL;
 }
 
-static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_session *ses)
+static __be32 nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_session *ses)
 {
 	struct nfs4_client *clp = ses->se_client;
 	struct nfsd4_conn *c;
+	__be32 status = nfs_ok;
 	int ret;
 
 	spin_lock(&clp->cl_lock);
 	c = __nfsd4_find_conn(new->cn_xprt, ses);
-	if (c) {
-		spin_unlock(&clp->cl_lock);
-		free_conn(new);
-		return;
-	}
+	if (c)
+		goto out_free;
+	status = nfserr_conn_not_bound_to_session;
+	if (clp->cl_mach_cred)
+		goto out_free;
 	__nfsd4_hash_conn(new, ses);
 	spin_unlock(&clp->cl_lock);
 	ret = nfsd4_register_conn(new);
 	if (ret)
 		/* oops; xprt is already down: */
 		nfsd4_conn_lost(&new->cn_xpt_user);
-	return;
+	return nfs_ok;
+out_free:
+	spin_unlock(&clp->cl_lock);
+	free_conn(new);
+	return status;
 }
 
 static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_session *session)
@@ -2172,8 +2209,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (status)
 		goto out_put_session;
 
-	nfsd4_sequence_check_conn(conn, session);
+	status = nfsd4_sequence_check_conn(conn, session);
 	conn = NULL;
+	if (status)
+		goto out_put_session;
 
 	/* Success! bump slot seqid */
 	slot->sl_seqid = seq->seqid;
@@ -2235,7 +2274,10 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		status = nfserr_stale_clientid;
 		goto out;
 	}
-
+	if (!mach_creds_match(clp, rqstp)) {
+		status = nfserr_wrong_cred;
+		goto out;
+	}
 	expire_client(clp);
 out:
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9aeacdd..6b83465 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3227,6 +3227,14 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 	return nfserr;
 }
 
+static const u32 nfs4_minimal_spo_must_enforce[2] = {
+	[1] = 1 << (OP_BIND_CONN_TO_SESSION - 32) |
+	      1 << (OP_EXCHANGE_ID - 32) |
+	      1 << (OP_CREATE_SESSION - 32) |
+	      1 << (OP_DESTROY_SESSION - 32) |
+	      1 << (OP_DESTROY_CLIENTID - 32)
+};
+
 static __be32
 nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 			 struct nfsd4_exchange_id *exid)
@@ -3265,6 +3273,20 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 	/* state_protect4_r. Currently only support SP4_NONE */
 	BUG_ON(exid->spa_how != SP4_NONE);
 	WRITE32(exid->spa_how);
+	switch (exid->spa_how) {
+	case SP4_NONE:
+		break;
+	case SP4_MACH_CRED:
+		/* spo_must_enforce bitmap: */
+		WRITE32(2);
+		WRITE32(nfs4_minimal_spo_must_enforce[0]);
+		WRITE32(nfs4_minimal_spo_must_enforce[1]);
+		/* empty spo_must_allow bitmap: */
+		WRITE32(0);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+	}
 
 	/* The server_owner struct */
 	WRITE64(minor_id);      /* Minor id */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 274e2a1..424d8f5 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -246,6 +246,7 @@ struct nfs4_client {
 	nfs4_verifier		cl_verifier; 	/* generated by client */
 	time_t                  cl_time;        /* time of last lease renewal */
 	struct sockaddr_storage	cl_addr; 	/* client ipaddress */
+	bool			cl_mach_cred;	/* SP4_MACH_CRED in force */
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
-- 
1.7.9.5

