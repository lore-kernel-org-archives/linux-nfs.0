Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:60659 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867AbaG3M1w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:27:52 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so1303500qgf.17
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:27:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 05/37] nfsd: Protect unconfirmed client creation using client_lock
Date: Wed, 30 Jul 2014 08:27:06 -0400
Message-Id: <1406723258-8512-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

...instead of relying on the client_mutex.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4b42cb95e315..f149e30475db 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1923,7 +1923,7 @@ add_to_unconfirmed(struct nfs4_client *clp)
 	add_clp_to_name_tree(clp, &nn->unconf_name_tree);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &nn->unconf_id_hashtbl[idhashval]);
-	renew_client(clp);
+	renew_client_locked(clp);
 }
 
 static void
@@ -1937,7 +1937,7 @@ move_to_confirmed(struct nfs4_client *clp)
 	rb_erase(&clp->cl_namenode, &nn->unconf_name_tree);
 	add_clp_to_name_tree(clp, &nn->conf_name_tree);
 	set_bit(NFSD4_CLIENT_CONFIRMED, &clp->cl_flags);
-	renew_client(clp);
+	renew_client_locked(clp);
 }
 
 static struct nfs4_client *
@@ -1950,7 +1950,7 @@ find_client_in_id_table(struct list_head *tbl, clientid_t *clid, bool sessions)
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
 				return NULL;
-			renew_client(clp);
+			renew_client_locked(clp);
 			return clp;
 		}
 	}
@@ -2152,7 +2152,8 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		  struct nfsd4_compound_state *cstate,
 		  struct nfsd4_exchange_id *exid)
 {
-	struct nfs4_client *unconf, *conf, *new;
+	struct nfs4_client *conf, *new;
+	struct nfs4_client *unconf = NULL;
 	__be32 status;
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
@@ -2187,6 +2188,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
 	if (conf) {
 		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
@@ -2218,7 +2220,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 				status = nfserr_clid_inuse;
 				goto out;
 			}
-			expire_client(conf);
 			goto out_new;
 		}
 		if (verfs_match) { /* case 2 */
@@ -2226,6 +2227,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			goto out_copy;
 		}
 		/* case 5, client reboot */
+		conf = NULL;
 		goto out_new;
 	}
 
@@ -2236,17 +2238,18 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
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
@@ -2259,9 +2262,12 @@ out_copy:
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
 
@@ -2900,7 +2906,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct xdr_netobj 	clname = setclid->se_name;
 	nfs4_verifier		clverifier = setclid->se_verf;
-	struct nfs4_client	*conf, *unconf, *new;
+	struct nfs4_client	*conf, *new;
+	struct nfs4_client	*unconf = NULL;
 	__be32 			status;
 	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
@@ -2909,6 +2916,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_jukebox;
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
+	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
 	if (conf) {
 		/* case 0: */
@@ -2926,7 +2934,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	unconf = find_unconfirmed_client_by_name(&clname, nn);
 	if (unconf)
-		expire_client(unconf);
+		unhash_client_locked(unconf);
 	if (conf && same_verf(&conf->cl_verifier, &clverifier))
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
@@ -2941,9 +2949,12 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

