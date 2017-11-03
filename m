Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:52635 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756151AbdKCMA2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 08:00:28 -0400
Received: by mail-io0-f195.google.com with SMTP id f20so5677950ioj.9
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 05:00:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/7] nfsd: Ensure we don't recognise lock stateids after freeing them
Date: Fri,  3 Nov 2017 08:00:13 -0400
Message-Id: <20171103120016.6200-5-trond.myklebust@primarydata.com>
In-Reply-To: <20171103120016.6200-4-trond.myklebust@primarydata.com>
References: <20171103120016.6200-1-trond.myklebust@primarydata.com>
 <20171103120016.6200-2-trond.myklebust@primarydata.com>
 <20171103120016.6200-3-trond.myklebust@primarydata.com>
 <20171103120016.6200-4-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to deal with lookup races, nfsd4_free_lock_stateid() needs
to be able to signal to other stateful functions that the lock stateid
is no longer valid. Right now, nfsd_lock() will check whether or not an
existing stateid is still hashed, but only in the "new lock" path.

To ensure the stateid invalidation is also recognised by the "existing lock"
path, and also by a second call to nfsd4_free_lock_stateid() itself, we can
change the type to NFS4_CLOSED_STID under the stp->st_mutex.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5ae6baff09e0..f93ca0682aaa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5076,7 +5076,9 @@ nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stid *s)
 	struct nfs4_ol_stateid *stp = openlockstateid(s);
 	__be32 ret;
 
-	mutex_lock(&stp->st_mutex);
+	ret = nfsd4_lock_ol_stateid(stp);
+	if (ret)
+		goto out_put_stid;
 
 	ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
 	if (ret)
@@ -5087,11 +5089,13 @@ nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stid *s)
 			    lockowner(stp->st_stateowner)))
 		goto out;
 
+	stp->st_stid.sc_type = NFS4_CLOSED_STID;
 	release_lock_stateid(stp);
 	ret = nfs_ok;
 
 out:
 	mutex_unlock(&stp->st_mutex);
+out_put_stid:
 	nfs4_put_stid(s);
 	return ret;
 }
@@ -5660,6 +5664,8 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	lockdep_assert_held(&clp->cl_lock);
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
+		if (lst->st_stid.sc_type != NFS4_LOCK_STID)
+			continue;
 		if (lst->st_stid.sc_file == fp) {
 			atomic_inc(&lst->st_stid.sc_count);
 			return lst;
@@ -5734,7 +5740,6 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 	struct nfs4_lockowner *lo;
 	struct nfs4_ol_stateid *lst;
 	unsigned int strhashval;
-	bool hashed;
 
 	lo = find_lockowner_str(cl, &lock->lk_new_owner);
 	if (!lo) {
@@ -5757,15 +5762,7 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	mutex_lock(&lst->st_mutex);
-
-	/* See if it's still hashed to avoid race with FREE_STATEID */
-	spin_lock(&cl->cl_lock);
-	hashed = !list_empty(&lst->st_perfile);
-	spin_unlock(&cl->cl_lock);
-
-	if (!hashed) {
-		mutex_unlock(&lst->st_mutex);
+	if (nfsd4_lock_ol_stateid(lst) != nfs_ok) {
 		nfs4_put_stid(&lst->st_stid);
 		goto retry;
 	}
-- 
2.13.6

