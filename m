Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:37069 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278AbaGHSFV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:21 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so5703861qcy.29
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 031/100] nfsd: clean up races in lock stateid searching and creation
Date: Tue,  8 Jul 2014 14:03:19 -0400
Message-Id: <1404842668-22521-32-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preparation for removal of the client_mutex.

Currently, no lock aside from the client_mutex is held when calling
find_lock_state. Ensure that the cl_lock is held by adding a lockdep
assertion.

Once we remove the client_mutex, it'll be possible for another thread to
race in and insert a lock state for the same file after we search but
before we insert a new one. Ensure that doesn't happen by redoing the
search after allocating a new stid that we plan to insert. If one is
found just put the one we just allocated.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 58 +++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 41 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 32538c79f9cb..2b8ca8354b95 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4694,16 +4694,14 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	return lo;
 }
 
-static struct nfs4_ol_stateid *
-alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
+static void
+init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
+		  struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
 {
-	struct nfs4_openowner *oo = openowner(open_stp->st_stateowner);
-	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
 
-	stp = nfs4_alloc_stateid(clp);
-	if (stp == NULL)
-		return NULL;
+	lockdep_assert_held(&clp->cl_lock);
+
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
@@ -4712,20 +4710,20 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
-	spin_lock(&oo->oo_owner.so_client->cl_lock);
 	list_add(&stp->st_locks, &open_stp->st_locks);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	spin_lock(&fp->fi_lock);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	spin_unlock(&fp->fi_lock);
-	spin_unlock(&oo->oo_owner.so_client->cl_lock);
-	return stp;
 }
 
 static struct nfs4_ol_stateid *
 find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 {
 	struct nfs4_ol_stateid *lst;
+	struct nfs4_client *clp = lo->lo_owner.so_client;
+
+	lockdep_assert_held(&clp->cl_lock);
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
 		if (lst->st_stid.sc_file == fp)
@@ -4734,6 +4732,36 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	return NULL;
 }
 
+static struct nfs4_ol_stateid *
+find_or_create_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fi,
+			    struct nfs4_ol_stateid *ost, bool *new)
+{
+	struct nfs4_ol_stateid *lst, *nst = NULL;
+	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
+	struct nfs4_client *clp = oo->oo_owner.so_client;
+
+	spin_lock(&clp->cl_lock);
+	lst = find_lock_stateid(lo, fi);
+	if (lst == NULL) {
+		spin_unlock(&clp->cl_lock);
+		nst = nfs4_alloc_stateid(clp);
+		if (nst == NULL)
+			return NULL;
+
+		spin_lock(&clp->cl_lock);
+		lst = find_lock_stateid(lo, fi);
+		if (likely(!lst)) {
+			init_lock_stateid(nst, lo, fi, ost);
+			lst = nst;
+			nst = NULL;
+			*new = true;
+		}
+	}
+	spin_unlock(&clp->cl_lock);
+	if (nst)
+		put_generic_stateid(nst);
+	return lst;
+}
 
 static int
 check_lock_length(u64 offset, u64 length)
@@ -4777,14 +4805,10 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 			return nfserr_bad_seqid;
 	}
 
-	*lst = find_lock_stateid(lo, fi);
+	*lst = find_or_create_lock_stateid(lo, fi, ost, new);
 	if (*lst == NULL) {
-		*lst = alloc_init_lock_stateid(lo, fi, ost);
-		if (*lst == NULL) {
-			release_lockowner_if_empty(lo);
-			return nfserr_jukebox;
-		}
-		*new = true;
+		release_lockowner_if_empty(lo);
+		return nfserr_jukebox;
 	}
 	return nfs_ok;
 }
-- 
1.9.3

