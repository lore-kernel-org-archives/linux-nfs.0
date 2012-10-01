Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34821 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776Ab2JARtI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:49:08 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TIk79-0007xu-UY
	for linux-nfs@vger.kernel.org; Mon, 01 Oct 2012 13:49:07 -0400
Date: Mon, 1 Oct 2012 13:49:07 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: don't allow reclaims of expired clients
Message-ID: <20121001174907.GA30556@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One more patch for 3.7--we were being a little inconsistent about
stable-storage records for 4.1 clients, with the result that reclaims
might be permitted in a few minor cases when they shouldn't be.  Fix
that and do a little cleanup.

--b.

commit 2047128b38fca41482d1ce4c7b760f80866de712
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Sep 26 11:36:16 2012 -0400

    nfsd4: don't allow reclaims of expired clients
    
    When a confirmed client expires, we normally also need to expire any
    stable storage record which would allow that client to reclaim state on
    the next boot.  We forgot to do this in some cases.  (For example, in
    destroy_clientid, and in the cases in exchange_id and create_session
    that destroy and existing confirmed client.)
    
    But in most other cases, there's really no harm to calling
    nfsd4_client_record_remove(), because it is a no-op in the case the
    client doesn't have an existing
    
    The single exception is destroying a client on shutdown, when we want to
    keep the stable storage records so we can recognize which clients will
    be allowed to reclaim when we come back up.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 773b903..412b888 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1118,7 +1118,7 @@ unhash_client_locked(struct nfs4_client *clp)
 }
 
 static void
-expire_client(struct nfs4_client *clp)
+destroy_client(struct nfs4_client *clp)
 {
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
@@ -1152,6 +1152,12 @@ expire_client(struct nfs4_client *clp)
 	spin_unlock(&client_lock);
 }
 
+static void expire_client(struct nfs4_client *clp)
+{
+	nfsd4_client_record_remove(clp);
+	destroy_client(clp);
+}
+
 static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
 {
 	memcpy(target->cl_verifier.data, source->data,
@@ -2273,10 +2279,8 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		unsigned int hash = clientstr_hashval(unconf->cl_recdir);
 
 		conf = find_confirmed_client_by_str(unconf->cl_recdir, hash);
-		if (conf) {
-			nfsd4_client_record_remove(conf);
+		if (conf)
 			expire_client(conf);
-		}
 		move_to_confirmed(unconf);
 		nfsd4_probe_callback(unconf);
 	}
@@ -3191,7 +3195,6 @@ nfs4_laundromat(void)
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
 			clp->cl_clientid.cl_id);
-		nfsd4_client_record_remove(clp);
 		expire_client(clp);
 	}
 	spin_lock(&recall_lock);
@@ -4562,7 +4565,6 @@ void nfsd_forget_clients(u64 num)
 
 	nfs4_lock_state();
 	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
-		nfsd4_client_record_remove(clp);
 		expire_client(clp);
 		if (++count == num)
 			break;
@@ -4787,11 +4789,11 @@ __nfs4_state_shutdown(void)
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		while (!list_empty(&conf_id_hashtbl[i])) {
 			clp = list_entry(conf_id_hashtbl[i].next, struct nfs4_client, cl_idhash);
-			expire_client(clp);
+			destroy_client(clp);
 		}
 		while (!list_empty(&unconf_str_hashtbl[i])) {
 			clp = list_entry(unconf_str_hashtbl[i].next, struct nfs4_client, cl_strhash);
-			expire_client(clp);
+			destroy_client(clp);
 		}
 	}
 	INIT_LIST_HEAD(&reaplist);
