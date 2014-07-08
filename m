Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:58244 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350AbaGHSFv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:51 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so5543300qcy.4
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 055/100] nfsd: Protect adding/removing lock owners using client_lock
Date: Tue,  8 Jul 2014 14:03:43 -0400
Message-Id: <1404842668-22521-56-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Once we remove client mutex protection, we'll need to ensure that
stateowner lookup and creation are atomic between concurrent compounds.
Ensure that alloc_init_lock_stateowner checks the hashtable under the
client_lock before adding a new element.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 69 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 61 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 743a48b6e84a..18ab6550d65d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -964,26 +964,42 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	put_generic_stateid(stp);
 }
 
-static void unhash_lockowner(struct nfs4_lockowner *lo)
+static void unhash_lockowner_locked(struct nfs4_lockowner *lo)
 {
+	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
+						nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
+
 	list_del_init(&lo->lo_owner.so_strhash);
 }
 
 static void release_lockowner_stateids(struct nfs4_lockowner *lo)
 {
+	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
+						nfsd_net_id);
 	struct nfs4_ol_stateid *stp;
 
+	lockdep_assert_held(&nn->client_lock);
+
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
+		spin_unlock(&nn->client_lock);
 		release_lock_stateid(stp);
+		spin_lock(&nn->client_lock);
 	}
 }
 
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
-	unhash_lockowner(lo);
+	struct nfsd_net *nn = net_generic(lo->lo_owner.so_client->net,
+						nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	unhash_lockowner_locked(lo);
 	release_lockowner_stateids(lo);
+	spin_unlock(&nn->client_lock);
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
@@ -4795,7 +4811,7 @@ nevermind:
 }
 
 static struct nfs4_lockowner *
-find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
+find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
 		struct nfsd_net *nn)
 {
 	unsigned int strhashval = ownerstr_hashval(clid->cl_id, owner);
@@ -4812,9 +4828,25 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 	return NULL;
 }
 
+static struct nfs4_lockowner *
+find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
+		struct nfsd_net *nn)
+{
+	struct nfs4_lockowner *lo;
+
+	spin_lock(&nn->client_lock);
+	lo = find_lockowner_str_locked(clid, owner, nn);
+	spin_unlock(&nn->client_lock);
+	return lo;
+}
+
 static void nfs4_unhash_lockowner(struct nfs4_stateowner *sop)
 {
-	unhash_lockowner(lockowner(sop));
+	struct nfsd_net *nn = net_generic(sop->so_client->net, nfsd_net_id);
+
+	spin_lock(&nn->client_lock);
+	unhash_lockowner_locked(lockowner(sop));
+	spin_unlock(&nn->client_lock);
 }
 
 static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
@@ -4833,9 +4865,12 @@ static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
  * strhashval = ownerstr_hashval
  */
 static struct nfs4_lockowner *
-alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp, struct nfsd4_lock *lock) {
-	struct nfs4_lockowner *lo;
+alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
+			   struct nfs4_ol_stateid *open_stp,
+			   struct nfsd4_lock *lock)
+{
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfs4_lockowner *lo, *ret;
 
 	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
 	if (!lo)
@@ -4845,7 +4880,16 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
 	lo->lo_owner.so_free = nfs4_free_lockowner;
 	lo->lo_owner.so_unhash = nfs4_unhash_lockowner;
-	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
+	spin_lock(&nn->client_lock);
+	ret = find_lockowner_str_locked(&clp->cl_clientid,
+			&lock->lk_new_owner, nn);
+	if (ret == NULL) {
+		list_add(&lo->lo_owner.so_strhash,
+			 &nn->ownerstr_hashtbl[strhashval]);
+		ret = lo;
+	} else
+		nfs4_free_lockowner(&lo->lo_owner);
+	spin_unlock(&nn->client_lock);
 	return lo;
 }
 
@@ -5373,6 +5417,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfs4_client *clp;
 
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);
@@ -5386,6 +5431,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	status = nfserr_locks_held;
 
 	/* Find the matching lock stateowner */
+	spin_lock(&nn->client_lock);
 	list_for_each_entry(tmp, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (tmp->so_is_open_owner)
 			continue;
@@ -5395,6 +5441,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			break;
 		}
 	}
+	spin_unlock(&nn->client_lock);
 
 	/* No matching owner found, maybe a replay? Just declare victory... */
 	if (!sop) {
@@ -5404,16 +5451,22 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 
 	lo = lockowner(sop);
 	/* see if there are still any locks associated with it */
+	clp = cstate->clp;
+	spin_lock(&clp->cl_lock);
 	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
 		if (check_for_locks(stp->st_stid.sc_file, lo)) {
-			nfs4_put_stateowner(sop);
+			spin_unlock(&clp->cl_lock);
 			goto out;
 		}
 	}
+	spin_unlock(&clp->cl_lock);
 
 	status = nfs_ok;
+	sop = NULL;
 	release_lockowner(lo);
 out:
+	if (sop)
+		nfs4_put_stateowner(sop);
 	nfs4_unlock_state();
 	return status;
 }
-- 
1.9.3

