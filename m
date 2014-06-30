Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:61589 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaF3Pw1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:27 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so6641106qab.1
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 081/114] nfsd: Protect unconfirmed client creation using client_lock
Date: Mon, 30 Jun 2014 11:49:50 -0400
Message-Id: <1404143423-24381-82-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

...instead of relying on the client_mutex.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d85985171cdd..8ec86da6eff8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1862,7 +1862,7 @@ add_to_unconfirmed(struct nfs4_client *clp)
 	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
-	renew_client(clp);
+	renew_client_locked(clp);
 }
 
 static void
@@ -1876,7 +1876,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	add_clp_to_name_tree(clp, &nn->conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
-	renew_client(clp);
+	renew_client_locked(clp);
 }
 
 static struct nfs4_client *
@@ -1889,7 +1889,7 @@ find_client_in_id_table(struct list_head *tbl, clientid_t *clid, bool sessions)
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
-			renew_client(clp);
+			renew_client_locked(clp);
 			return clp;
 		}
 	}
@@ -2091,7 +2091,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		  struct nfsd4_compound_state *cstate,
 		  struct nfsd4_exchange_id *exid)
 {
-	struct nfs4_client *unconf, *conf, *new;
+	struct nfs4_client *conf, *new;
+	struct nfs4_client *unconf = NULL;
 	__be32 status;
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
@@ -2126,6 +2127,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
 	if (conf) {
 		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
@@ -2157,7 +2159,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 				status = nfserr_clid_inuse;
 				goto out;
 			}
-			expire_client(conf);
 			goto out_new;
 		}
 		if (verfs_match) { /* case 2 */
@@ -2165,6 +2166,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			goto out_copy;
 		}
 		/* case 5, client reboot */
+		conf = NULL;
 		goto out_new;
 	}
 
@@ -2175,17 +2177,18 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
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
@@ -2198,9 +2201,12 @@ out_copy:
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
 
@@ -2839,7 +2845,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct xdr_netobj 	clname = setclid->se_name;
 	nfs4_verifier		clverifier = setclid->se_verf;
-	struct nfs4_client	*conf, *unconf, *new;
+	struct nfs4_client	*conf, *new;
+	struct nfs4_client	*unconf = NULL;
 	__be32 			status;
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
@@ -2848,6 +2855,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
 		/* case 0: */
@@ -2865,7 +2873,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	unconf = find_unconfirmed_client_by_name(&clname, nn);
 	if (unconf)
-		expire_client(unconf);
+		unhash_client_locked(unconf);
 	if (conf && same_verf(&conf->cl_verifier, &clverifier))
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
@@ -2880,9 +2888,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
1.9.3

