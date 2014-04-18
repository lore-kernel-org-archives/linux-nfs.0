Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39278 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbaDRSpg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:36 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so1899706iec.3
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 20/70] NFSd: NFSv4 lock-owners are not associated to a specific file
Date: Fri, 18 Apr 2014 14:44:14 -0400
Message-Id: <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just like open-owners, lock-owners are associated with a name, a clientid
and, in the case of minor version 0, a sequence id. There is no association
to a file.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 38 +++++++++++++-------------------------
 1 file changed, 13 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dad2f7b511b8..be48dbc32f97 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4249,8 +4249,7 @@ last_byte_offset(u64 start, u64 len)
 
 static unsigned int lockowner_ino_hashval(struct inode *inode, u32 cl_id, struct xdr_netobj *ownername)
 {
-	return (file_hashval(inode) + cl_id
-			+ opaque_hashval(ownername->data, ownername->len))
+	return (cl_id + opaque_hashval(ownername->data, ownername->len))
 		& LOCKOWNER_INO_HASH_MASK;
 }
 
@@ -4306,27 +4305,19 @@ nevermind:
 		deny->ld_type = NFS4_WRITE_LT;
 }
 
-static bool same_lockowner_ino(struct nfs4_lockowner *lo, struct inode *inode, clientid_t *clid, struct xdr_netobj *owner)
-{
-	struct nfs4_ol_stateid *lst;
-
-	if (!same_owner_str(&lo->lo_owner, owner, clid))
-		return false;
-	lst = list_first_entry(&lo->lo_owner.so_stateids,
-			       struct nfs4_ol_stateid, st_perstateowner);
-	return lst->st_file->fi_inode == inode;
-}
-
 static struct nfs4_lockowner *
-find_lockowner_str(struct inode *inode, clientid_t *clid,
-		   struct xdr_netobj *owner, struct nfsd_net *nn)
+find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
+		struct nfsd_net *nn)
 {
-	unsigned int hashval = lockowner_ino_hashval(inode, clid->cl_id, owner);
-	struct nfs4_lockowner *lo;
+	unsigned int strhashval = ownerstr_hashval(clid->cl_id, owner);
+	struct nfs4_stateowner *so;
 
-	list_for_each_entry(lo, &nn->lockowner_ino_hashtbl[hashval], lo_owner_ino_hash) {
-		if (same_lockowner_ino(lo, inode, clid, owner))
-			return lo;
+	list_for_each_entry(so, &nn->ownerstr_hashtbl[strhashval], so_strhash) {
+		if (so->so_is_open_owner)
+			continue;
+		if (!same_owner_str(so, owner, clid))
+			continue;
+		return lockowner(so);
 	}
 	return NULL;
 }
@@ -4430,8 +4421,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 	unsigned int strhashval;
 	struct nfsd_net *nn = net_generic(cl->net, nfsd_net_id);
 
-	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid,
-				&lock->v.new.owner, nn);
+	lo = find_lockowner_str(&cl->cl_clientid, &lock->v.new.owner, nn);
 	if (!lo) {
 		strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
 				&lock->v.new.owner);
@@ -4642,7 +4632,6 @@ __be32
 nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_lockt *lockt)
 {
-	struct inode *inode;
 	struct file_lock *file_lock = NULL;
 	struct nfs4_lockowner *lo;
 	__be32 status;
@@ -4665,7 +4654,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		goto out;
 
-	inode = cstate->current_fh.fh_dentry->d_inode;
 	file_lock = locks_alloc_lock();
 	if (!file_lock) {
 		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
@@ -4688,7 +4676,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	lo = find_lockowner_str(inode, &lockt->lt_clientid, &lockt->lt_owner, nn);
+	lo = find_lockowner_str(&lockt->lt_clientid, &lockt->lt_owner, nn);
 	if (lo)
 		file_lock->fl_owner = (fl_owner_t)lo;
 	file_lock->fl_pid = current->tgid;
-- 
1.9.0

