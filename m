Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36567 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbbGMJfl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:35:41 -0400
Received: by pachj5 with SMTP id hj5so29341263pac.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:35:41 -0700 (PDT)
Message-ID: <55A38669.6050903@gmail.com>
Date: Mon, 13 Jul 2015 17:35:37 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 14/14] nfsd: Remove unused clientid arguments from, find_lockowner_str{_locked}
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2704270..b6c134d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5131,8 +5131,7 @@ nevermind:
 }
 
 static struct nfs4_lockowner *
-find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
-		struct nfs4_client *clp)
+find_lockowner_str_locked(struct nfs4_client *clp, struct xdr_netobj *owner)
 {
 	unsigned int strhashval = ownerstr_hashval(owner);
 	struct nfs4_stateowner *so;
@@ -5150,13 +5149,12 @@ find_lockowner_str_locked(clientid_t *clid, struct xdr_netobj *owner,
 }
 
 static struct nfs4_lockowner *
-find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
-		struct nfs4_client *clp)
+find_lockowner_str(struct nfs4_client *clp, struct xdr_netobj *owner)
 {
 	struct nfs4_lockowner *lo;
 
 	spin_lock(&clp->cl_lock);
-	lo = find_lockowner_str_locked(clid, owner, clp);
+	lo = find_lockowner_str_locked(clp, owner);
 	spin_unlock(&clp->cl_lock);
 	return lo;
 }
@@ -5200,8 +5198,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid;
 	lo->lo_owner.so_ops = &lockowner_ops;
 	spin_lock(&clp->cl_lock);
-	ret = find_lockowner_str_locked(&clp->cl_clientid,
-			&lock->lk_new_owner, clp);
+	ret = find_lockowner_str_locked(clp, &lock->lk_new_owner);
 	if (ret == NULL) {
 		list_add(&lo->lo_owner.so_strhash,
 			 &clp->cl_ownerstr_hashtbl[strhashval]);
@@ -5322,7 +5319,7 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 	struct nfs4_lockowner *lo;
 	unsigned int strhashval;
 
-	lo = find_lockowner_str(&cl->cl_clientid, &lock->lk_new_owner, cl);
+	lo = find_lockowner_str(cl, &lock->lk_new_owner);
 	if (!lo) {
 		strhashval = ownerstr_hashval(&lock->lk_new_owner);
 		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
@@ -5597,8 +5594,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	lo = find_lockowner_str(&lockt->lt_clientid, &lockt->lt_owner,
-				cstate->clp);
+	lo = find_lockowner_str(cstate->clp, &lockt->lt_owner);
 	if (lo)
 		file_lock->fl_owner = (fl_owner_t)lo;
 	file_lock->fl_pid = current->tgid;
-- 
2.4.3

