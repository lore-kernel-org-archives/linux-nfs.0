Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34773 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbaDRSpf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:35 -0400
Received: by mail-ig0-f170.google.com with SMTP id uq10so1223010igb.1
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 19/70] NFSd: Allow lockowners to hold several stateids
Date: Fri, 18 Apr 2014 14:44:13 -0400
Message-Id: <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 46 +++++++++++++++++++++++++++++-----------------
 1 file changed, 29 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0809e8355577..dad2f7b511b8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4390,6 +4390,19 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	return stp;
 }
 
+static struct nfs4_ol_stateid *
+find_lock_stateid(struct nfs4_lockowner *lo, struct inode *inode)
+{
+	struct nfs4_ol_stateid *lst;
+
+	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
+		if (lst->st_file->fi_inode == inode)
+			return lst;
+	}
+	return NULL;
+}
+
+
 static int
 check_lock_length(u64 offset, u64 length)
 {
@@ -4419,25 +4432,24 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 
 	lo = find_lockowner_str(fi->fi_inode, &cl->cl_clientid,
 				&lock->v.new.owner, nn);
-	if (lo) {
-		if (!cstate->minorversion)
-			return nfserr_bad_seqid;
-		/* XXX: a lockowner always has exactly one stateid: */
-		*lst = list_first_entry(&lo->lo_owner.so_stateids,
-				struct nfs4_ol_stateid, st_perstateowner);
-		return nfs_ok;
+	if (!lo) {
+		strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
+				&lock->v.new.owner);
+		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
+		if (lo == NULL)
+			return nfserr_jukebox;
 	}
-	strhashval = ownerstr_hashval(cl->cl_clientid.cl_id,
-			&lock->v.new.owner);
-	lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
-	if (lo == NULL)
-		return nfserr_jukebox;
-	*lst = alloc_init_lock_stateid(lo, fi, ost);
+	if (!cstate->minorversion)
+		return nfserr_bad_seqid;
+	*lst = find_lock_stateid(lo, fi->fi_inode);
 	if (*lst == NULL) {
-		release_lockowner(lo);
-		return nfserr_jukebox;
+		*lst = alloc_init_lock_stateid(lo, fi, ost);
+		if (*lst == NULL) {
+			release_lockowner_if_empty(lo);
+			return nfserr_jukebox;
+		}
+		*new = true;
 	}
-	*new = true;
 	return nfs_ok;
 }
 
@@ -4596,7 +4608,7 @@ out:
 	if (filp)
 		fput(filp);
 	if (status && new_state)
-		release_lockowner(lock_sop);
+		release_lockowner_if_empty(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
 	if (file_lock)
-- 
1.9.0

