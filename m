Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:34598 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374AbbHVOwZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Aug 2015 10:52:25 -0400
Received: by ykdt205 with SMTP id t205so97428649ykd.1
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2015 07:52:24 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd: ensure that the ol stateid hash reference is only put once
Date: Sat, 22 Aug 2015 10:52:16 -0400
Message-Id: <1440255137-10642-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440255137-10642-1-git-send-email-jeff.layton@primarydata.com>
References: <1440255137-10642-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When an open or lock stateid is hashed, we take an extra reference to
it. When we unhash it, we drop that reference. The code however does
not properly account for the case where we have two callers concurrently
trying to unhash the stateid. This can lead to list corruption and the
hash reference being put more than once.

Fix this by having unhash_ol_stateid use list_del_init on the st_perfile
list_head, and then testing to see if that list_head is empty before
releasing the hash reference. This means that some of the unhashing
wrappers now become bool return functions so we can test to see whether
the stateid was unhashed before we put the reference.

Reported-by: Andrew W Elble <aweits@rit.edu>
Reported-by: Anna Schumaker <Anna.Schumaker@netapp.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 50 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 32 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ef9cb8f5f758..c2448ffd6b8e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1011,16 +1011,20 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 	nfs4_free_stateowner(sop);
 }
 
-static void unhash_ol_stateid(struct nfs4_ol_stateid *stp)
+static bool unhash_ol_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_file *fp = stp->st_stid.sc_file;
 
 	lockdep_assert_held(&stp->st_stateowner->so_client->cl_lock);
 
+	if (list_empty(&stp->st_perfile))
+		return false;
+
 	spin_lock(&fp->fi_lock);
-	list_del(&stp->st_perfile);
+	list_del_init(&stp->st_perfile);
 	spin_unlock(&fp->fi_lock);
 	list_del(&stp->st_perstateowner);
+	return true;
 }
 
 static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
@@ -1073,25 +1077,27 @@ static void put_ol_stateid_locked(struct nfs4_ol_stateid *stp,
 	list_add(&stp->st_locks, reaplist);
 }
 
-static void unhash_lock_stateid(struct nfs4_ol_stateid *stp)
+static bool unhash_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
 
 	lockdep_assert_held(&oo->oo_owner.so_client->cl_lock);
 
 	list_del_init(&stp->st_locks);
-	unhash_ol_stateid(stp);
 	nfs4_unhash_stid(&stp->st_stid);
+	return unhash_ol_stateid(stp);
 }
 
 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
+	bool unhashed;
 
 	spin_lock(&oo->oo_owner.so_client->cl_lock);
-	unhash_lock_stateid(stp);
+	unhashed = unhash_lock_stateid(stp);
 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
-	nfs4_put_stid(&stp->st_stid);
+	if (unhashed)
+		nfs4_put_stid(&stp->st_stid);
 }
 
 static void unhash_lockowner_locked(struct nfs4_lockowner *lo)
@@ -1139,7 +1145,7 @@ static void release_lockowner(struct nfs4_lockowner *lo)
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		unhash_lock_stateid(stp);
+		WARN_ON(!unhash_lock_stateid(stp));
 		put_ol_stateid_locked(stp, &reaplist);
 	}
 	spin_unlock(&clp->cl_lock);
@@ -1152,21 +1158,26 @@ static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp,
 {
 	struct nfs4_ol_stateid *stp;
 
+	lockdep_assert_held(&open_stp->st_stid.sc_client->cl_lock);
+
 	while (!list_empty(&open_stp->st_locks)) {
 		stp = list_entry(open_stp->st_locks.next,
 				struct nfs4_ol_stateid, st_locks);
-		unhash_lock_stateid(stp);
+		WARN_ON(!unhash_lock_stateid(stp));
 		put_ol_stateid_locked(stp, reaplist);
 	}
 }
 
-static void unhash_open_stateid(struct nfs4_ol_stateid *stp,
+static bool unhash_open_stateid(struct nfs4_ol_stateid *stp,
 				struct list_head *reaplist)
 {
+	bool unhashed;
+
 	lockdep_assert_held(&stp->st_stid.sc_client->cl_lock);
 
-	unhash_ol_stateid(stp);
+	unhashed = unhash_ol_stateid(stp);
 	release_open_stateid_locks(stp, reaplist);
+	return unhashed;
 }
 
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
@@ -1174,8 +1185,8 @@ static void release_open_stateid(struct nfs4_ol_stateid *stp)
 	LIST_HEAD(reaplist);
 
 	spin_lock(&stp->st_stid.sc_client->cl_lock);
-	unhash_open_stateid(stp, &reaplist);
-	put_ol_stateid_locked(stp, &reaplist);
+	if (unhash_open_stateid(stp, &reaplist))
+		put_ol_stateid_locked(stp, &reaplist);
 	spin_unlock(&stp->st_stid.sc_client->cl_lock);
 	free_ol_stateid_reaplist(&reaplist);
 }
@@ -1220,8 +1231,8 @@ static void release_openowner(struct nfs4_openowner *oo)
 	while (!list_empty(&oo->oo_owner.so_stateids)) {
 		stp = list_first_entry(&oo->oo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		unhash_open_stateid(stp, &reaplist);
-		put_ol_stateid_locked(stp, &reaplist);
+		if (unhash_open_stateid(stp, &reaplist))
+			put_ol_stateid_locked(stp, &reaplist);
 	}
 	spin_unlock(&clp->cl_lock);
 	free_ol_stateid_reaplist(&reaplist);
@@ -4752,7 +4763,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		if (check_for_locks(stp->st_stid.sc_file,
 				    lockowner(stp->st_stateowner)))
 			break;
-		unhash_lock_stateid(stp);
+		WARN_ON(!unhash_lock_stateid(stp));
 		spin_unlock(&cl->cl_lock);
 		nfs4_put_stid(s);
 		ret = nfs_ok;
@@ -4968,20 +4979,23 @@ out:
 static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 {
 	struct nfs4_client *clp = s->st_stid.sc_client;
+	bool unhashed;
 	LIST_HEAD(reaplist);
 
 	s->st_stid.sc_type = NFS4_CLOSED_STID;
 	spin_lock(&clp->cl_lock);
-	unhash_open_stateid(s, &reaplist);
+	unhashed = unhash_open_stateid(s, &reaplist);
 
 	if (clp->cl_minorversion) {
-		put_ol_stateid_locked(s, &reaplist);
+		if (unhashed)
+			put_ol_stateid_locked(s, &reaplist);
 		spin_unlock(&clp->cl_lock);
 		free_ol_stateid_reaplist(&reaplist);
 	} else {
 		spin_unlock(&clp->cl_lock);
 		free_ol_stateid_reaplist(&reaplist);
-		move_to_close_lru(s, clp->net);
+		if (unhashed)
+			move_to_close_lru(s, clp->net);
 	}
 }
 
-- 
2.4.3

