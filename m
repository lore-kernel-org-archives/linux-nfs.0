Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35992 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbcHKOhl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 10:37:41 -0400
Received: by mail-io0-f194.google.com with SMTP id y34so539919ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2016 07:37:40 -0700 (PDT)
Subject: [PATCH v4 2/2] nfsd: don't return an unhashed lock stateid after
 taking mutex
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Thu, 11 Aug 2016 10:37:39 -0400
Message-ID: <20160811143739.20488.81096.stgit@klimt.1015granger.net>
In-Reply-To: <20160811143205.20488.82396.stgit@klimt.1015granger.net>
References: <20160811143205.20488.82396.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

nfsd4_lock will take the st_mutex before working with the stateid it
gets, but between the time when we drop the cl_lock and take the mutex,
the stateid could become unhashed (a'la FREE_STATEID). If that happens
the lock stateid returned to the client will be forgotten.

Fix this by first moving the st_mutex acquisition into
lookup_or_create_lock_state. Then, have it check to see if the lock
stateid is still hashed after taking the mutex. If it's not, then put
the stateid and try the find/create again.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Tested-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 fs/nfsd/nfs4state.c |   25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index de868fe..6a23098 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5505,7 +5505,7 @@ static __be32
 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 			    struct nfs4_ol_stateid *ost,
 			    struct nfsd4_lock *lock,
-			    struct nfs4_ol_stateid **lst, bool *new)
+			    struct nfs4_ol_stateid **plst, bool *new)
 {
 	__be32 status;
 	struct nfs4_file *fi = ost->st_stid.sc_file;
@@ -5513,7 +5513,9 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct inode *inode = d_inode(cstate->current_fh.fh_dentry);
 	struct nfs4_lockowner *lo;
+	struct nfs4_ol_stateid *lst;
 	unsigned int strhashval;
+	bool hashed;
 
 	lo = find_lockowner_str(cl, &lock->lk_new_owner);
 	if (!lo) {
@@ -5529,12 +5531,27 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 			goto out;
 	}
 
-	*lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
-	if (*lst == NULL) {
+retry:
+	lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
+	if (lst == NULL) {
 		status = nfserr_jukebox;
 		goto out;
 	}
+
+	mutex_lock(&lst->st_mutex);
+
+	/* See if it's still hashed to avoid race with FREE_STATEID */
+	spin_lock(&cl->cl_lock);
+	hashed = !list_empty(&lst->st_perfile);
+	spin_unlock(&cl->cl_lock);
+
+	if (!hashed) {
+		mutex_unlock(&lst->st_mutex);
+		nfs4_put_stid(&lst->st_stid);
+		goto retry;
+	}
 	status = nfs_ok;
+	*plst = lst;
 out:
 	nfs4_put_stateowner(&lo->lo_owner);
 	return status;
@@ -5601,8 +5618,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		status = lookup_or_create_lock_state(cstate, open_stp, lock,
 							&lock_stp, &new);
-		if (status == nfs_ok)
-			mutex_lock(&lock_stp->st_mutex);
 	} else {
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,

