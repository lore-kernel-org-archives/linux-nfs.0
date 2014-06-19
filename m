Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:52157 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758067AbaFSOwU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:20 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so2277011qcw.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:19 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 056/104] NFSd: Protect adding/removing lock owners using client_lock
Date: Thu, 19 Jun 2014 10:50:02 -0400
Message-Id: <1403189450-18729-57-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

* Ensure that alloc_init_lock_stateowner() checks the hashtable
  under the lock before adding a new element.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 59 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 73c76a895015..a8969884f65e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -827,26 +827,42 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
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
 
 static void destroy_lockowner(struct nfs4_lockowner *lo)
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
 
@@ -4667,7 +4683,7 @@ nevermind:
 }
 
 static struct nfs4_lockowner *
-find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
+find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
 		struct nfsd_net *nn)
 {
 	unsigned int strhashval = ownerstr_hashval(clid->cl_id, owner);
@@ -4684,6 +4700,18 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
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
 static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
@@ -4693,7 +4721,11 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 
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
@@ -4712,8 +4744,10 @@ static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
  */
 
 static struct nfs4_lockowner *
-alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp, struct nfsd4_lock *lock) {
-	struct nfs4_lockowner *lo;
+alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp, struct nfsd4_lock *lock)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfs4_lockowner *lo, *ret;
 
 	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
 	if (!lo)
@@ -4721,9 +4755,17 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	INIT_LIST_HEAD(&lo->lo_owner.so_stateids);
 	lo->lo_owner.so_is_open_owner = 0;
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
-	hash_lockowner(lo, strhashval, clp);
 	lo->lo_owner.so_free = nfs4_free_lockowner;
 	lo->lo_owner.so_unhash = nfs4_unhash_lockowner;
+	spin_lock(&nn->client_lock);
+	ret = find_lockowner_str_locked(&clp->cl_clientid,
+			&lock->lk_new_owner, nn);
+	if (ret == NULL) {
+		hash_lockowner(lo, strhashval, clp);
+		ret = lo;
+	} else
+		nfs4_free_lockowner(&lo->lo_owner);
+	spin_unlock(&nn->client_lock);
 	return lo;
 }
 
@@ -5244,6 +5286,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfs4_client *clp;
 
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);
@@ -5258,6 +5301,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	INIT_LIST_HEAD(&matches);
 
 	/* Find the matching lock stateowner */
+	spin_lock(&nn->client_lock);
 	list_for_each_entry(tmp, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (tmp->so_is_open_owner)
 			continue;
@@ -5267,6 +5311,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			break;
 		}
 	}
+	spin_unlock(&nn->client_lock);
 
 	/* No matching owner found, maybe a replay? Just declare victory... */
 	if (!sop) {
@@ -5276,16 +5321,22 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 
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
 	destroy_lockowner(lo);
 out:
+	if (sop)
+		nfs4_put_stateowner(sop);
 	nfs4_unlock_state();
 	return status;
 }
-- 
1.9.3

