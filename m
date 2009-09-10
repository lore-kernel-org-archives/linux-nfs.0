From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 12/12] nfsd41: Refactor create_client()
Date: Thu, 10 Sep 2009 12:27:34 +0300
Message-ID: <1252574854-30417-1-git-send-email-bhalevy@panasas.com>
References: <4AA8C597.8080809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:8104 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752538AbZIJJ1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 05:27:05 -0400
In-Reply-To: <4AA8C597.8080809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Move common initialization of 'struct nfs4_client' inside create_client().

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: Remember the auth flavor to use for callbacks]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   89 ++++++++++++++++++++++++++-------------------------
 1 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b2ffa3b..f344de2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -763,27 +763,6 @@ expire_client(struct nfs4_client *clp)
 	put_nfs4_client(clp);
 }
 
-static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
-{
-	struct nfs4_client *clp;
-
-	clp = alloc_client(name);
-	if (clp == NULL)
-		return NULL;
-	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
-	atomic_set(&clp->cl_count, 1);
-	atomic_set(&clp->cl_cb_conn.cb_set, 0);
-	INIT_LIST_HEAD(&clp->cl_idhash);
-	INIT_LIST_HEAD(&clp->cl_strhash);
-	INIT_LIST_HEAD(&clp->cl_openowners);
-	INIT_LIST_HEAD(&clp->cl_delegations);
-	INIT_LIST_HEAD(&clp->cl_sessions);
-	INIT_LIST_HEAD(&clp->cl_lru);
-	clear_bit(0, &clp->cl_cb_slot_busy);
-	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
-	return clp;
-}
-
 static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
 {
 	memcpy(target->cl_verifier.data, source->data,
@@ -846,6 +825,46 @@ static void gen_confirm(struct nfs4_client *clp)
 	*p++ = i++;
 }
 
+static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
+		struct svc_rqst *rqstp, nfs4_verifier *verf)
+{
+	struct nfs4_client *clp;
+	struct sockaddr *sa = svc_addr(rqstp);
+	char *princ;
+
+	clp = alloc_client(name);
+	if (clp == NULL)
+		return NULL;
+
+	princ = svc_gss_principal(rqstp);
+	if (princ) {
+		clp->cl_principal = kstrdup(princ, GFP_KERNEL);
+		if (clp->cl_principal == NULL) {
+			free_client(clp);
+			return NULL;
+		}
+	}
+
+	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
+	atomic_set(&clp->cl_count, 1);
+	atomic_set(&clp->cl_cb_conn.cb_set, 0);
+	INIT_LIST_HEAD(&clp->cl_idhash);
+	INIT_LIST_HEAD(&clp->cl_strhash);
+	INIT_LIST_HEAD(&clp->cl_openowners);
+	INIT_LIST_HEAD(&clp->cl_delegations);
+	INIT_LIST_HEAD(&clp->cl_sessions);
+	INIT_LIST_HEAD(&clp->cl_lru);
+	clear_bit(0, &clp->cl_cb_slot_busy);
+	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
+	copy_verf(clp, verf);
+	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
+	clp->cl_flavor = rqstp->rq_flavor;
+	copy_cred(&clp->cl_cred, &rqstp->rq_cred);
+	gen_confirm(clp);
+
+	return clp;
+}
+
 static int check_name(struct xdr_netobj name)
 {
 	if (name.len == 0) 
@@ -1193,17 +1212,13 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 out_new:
 	/* Normal case */
-	new = create_client(exid->clname, dname);
+	new = create_client(exid->clname, dname, rqstp, &verf);
 	if (new == NULL) {
 		status = nfserr_serverfault;
 		goto out;
 	}
 
-	copy_verf(new, &verf);
-	copy_cred(&new->cl_cred, &rqstp->rq_cred);
-	rpc_copy_addr((struct sockaddr *) &new->cl_addr, sa);
 	gen_clid(new);
-	gen_confirm(new);
 	add_to_unconfirmed(new, strhashval);
 out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
@@ -1477,7 +1492,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	unsigned int 		strhashval;
 	struct nfs4_client	*conf, *unconf, *new;
 	__be32 			status;
-	char			*princ;
 	char                    dname[HEXDIR_LEN];
 	
 	if (!check_name(clname))
@@ -1522,7 +1536,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 */
 		if (unconf)
 			expire_client(unconf);
-		new = create_client(clname, dname);
+		new = create_client(clname, dname, rqstp, &clverifier);
 		if (new == NULL)
 			goto out;
 		gen_clid(new);
@@ -1539,7 +1553,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			 */
 			expire_client(unconf);
 		}
-		new = create_client(clname, dname);
+		new = create_client(clname, dname, rqstp, &clverifier);
 		if (new == NULL)
 			goto out;
 		copy_clid(new, conf);
@@ -1549,7 +1563,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * probable client reboot; state will be removed if
 		 * confirmed.
 		 */
-		new = create_client(clname, dname);
+		new = create_client(clname, dname, rqstp, &clverifier);
 		if (new == NULL)
 			goto out;
 		gen_clid(new);
@@ -1560,24 +1574,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * confirmed.
 		 */
 		expire_client(unconf);
-		new = create_client(clname, dname);
+		new = create_client(clname, dname, rqstp, &clverifier);
 		if (new == NULL)
 			goto out;
 		gen_clid(new);
 	}
-	copy_verf(new, &clverifier);
-	rpc_copy_addr((struct sockaddr *) &new->cl_addr, sa);
-	new->cl_flavor = rqstp->rq_flavor;
-	princ = svc_gss_principal(rqstp);
-	if (princ) {
-		new->cl_principal = kstrdup(princ, GFP_KERNEL);
-		if (new->cl_principal == NULL) {
-			free_client(new);
-			goto out;
-		}
-	}
-	copy_cred(&new->cl_cred, &rqstp->rq_cred);
-	gen_confirm(new);
 	gen_callback(new, setclid, rpc_get_scope_id(sa));
 	add_to_unconfirmed(new, strhashval);
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
-- 
1.6.4

