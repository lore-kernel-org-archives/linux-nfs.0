Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:58339 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541AbaDRSqj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:39 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so960779igc.14
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 57/70] NFSd: Protect unconfirmed client creation using client_lock
Date: Fri, 18 Apr 2014 14:44:51 -0400
Message-Id: <1397846704-14567-58-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-57-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 79948fd2ad9e..9c24031757d2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1633,7 +1633,7 @@ add_to_unconfirmed(struct nfs4_client *clp)
 	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
-	renew_client(clp);
+	renew_client_locked(clp);
 }
 
 static void
@@ -1647,7 +1647,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	add_clp_to_name_tree(clp, &nn->conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
-	renew_client(clp);
+	renew_client_locked(clp);
 }
 
 static struct nfs4_client *
@@ -1660,7 +1660,7 @@ find_client_in_id_table(struct list_head *tbl, clientid_t *clid, bool sessions)
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
-			renew_client(clp);
+			renew_client_locked(clp);
 			return clp;
 		}
 	}
@@ -1859,7 +1859,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		  struct nfsd4_compound_state *cstate,
 		  struct nfsd4_exchange_id *exid)
 {
-	struct nfs4_client *unconf, *conf, *new;
+	struct nfs4_client *conf, *new;
+	struct nfs4_client *unconf = NULL;
 	__be32 status;
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
@@ -1894,6 +1895,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
 	if (conf) {
 		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
@@ -1943,17 +1945,18 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	unconf  = find_unconfirmed_client_by_name(&exid->clname, nn);
 	if (unconf) /* case 4, possible retry or client restart */
-		expire_client(unconf);
+		unhash_client_locked(unconf);
 
 	/* case 1 (normal case) */
 out_new:
+	if (conf)
+		unhash_client_locked(conf);
 	new->cl_minorversion = cstate->minorversion;
 	new->cl_mach_cred = (exid->spa_how == SP4_MACH_CRED);
 
 	gen_clid(new, nn);
 	add_to_unconfirmed(new);
-	conf = new;
-	new = NULL;
+	swap(new, conf);
 out_copy:
 	exid->clientid.cl_boot = conf->cl_clientid.cl_boot;
 	exid->clientid.cl_id = conf->cl_clientid.cl_id;
@@ -1966,9 +1969,12 @@ out_copy:
 	status = nfs_ok;
 
 out:
+	spin_unlock(&nn->client_lock);
 	nfs4_unlock_state();
 	if (new)
-		free_client(new);
+		expire_client(new);
+	if (unconf)
+		expire_client(unconf);
 	return status;
 }
 
@@ -2592,7 +2598,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct xdr_netobj 	clname = setclid->se_name;
 	nfs4_verifier		clverifier = setclid->se_verf;
-	struct nfs4_client	*conf, *unconf, *new;
+	struct nfs4_client	*conf, *new;
+	struct nfs4_client	*unconf = NULL;
 	__be32 			status;
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
@@ -2601,6 +2608,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
 		/* case 0: */
@@ -2618,7 +2626,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	unconf = find_unconfirmed_client_by_name(&clname, nn);
 	if (unconf)
-		expire_client(unconf);
+		unhash_client_locked(unconf);
 	if (conf && same_verf(&conf->cl_verifier, &clverifier))
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
@@ -2633,9 +2641,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	new = NULL;
 	status = nfs_ok;
 out:
+	spin_unlock(&nn->client_lock);
 	nfs4_unlock_state();
 	if (new)
 		free_client(new);
+	if (unconf)
+		expire_client(unconf);
 	return status;
 }
 
-- 
1.9.0

