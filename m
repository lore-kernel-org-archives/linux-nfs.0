Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:52777 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbaG3BfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:05 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so578965qaq.29
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:01 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 08/38] nfsd: clean up races in lock stateid searching and creation
Date: Tue, 29 Jul 2014 21:34:13 -0400
Message-Id: <1406684083-19736-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
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
found just put the one that was allocated.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 71 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 49 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3ac6e2fdabe5..59d44873b68b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4719,20 +4719,15 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	return lo;
 }
 
-static struct nfs4_ol_stateid *
-alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp,
-		struct inode *inode,
-		struct nfs4_ol_stateid *open_stp)
+static void
+init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
+		  struct nfs4_file *fp, struct inode *inode,
+		  struct nfs4_ol_stateid *open_stp)
 {
-	struct nfs4_stid *s;
-	struct nfs4_openowner *oo = openowner(open_stp->st_stateowner);
-	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
 
-	s = nfs4_alloc_stid(clp, stateid_slab);
-	if (s == NULL)
-		return NULL;
-	stp = openlockstateid(s);
+	lockdep_assert_held(&clp->cl_lock);
+
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
@@ -4741,20 +4736,20 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp,
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
@@ -4763,6 +4758,38 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	return NULL;
 }
 
+static struct nfs4_ol_stateid *
+find_or_create_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fi,
+			    struct inode *inode, struct nfs4_ol_stateid *ost,
+			    bool *new)
+{
+	struct nfs4_stid *ns = NULL;
+	struct nfs4_ol_stateid *lst;
+	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
+	struct nfs4_client *clp = oo->oo_owner.so_client;
+
+	spin_lock(&clp->cl_lock);
+	lst = find_lock_stateid(lo, fi);
+	if (lst == NULL) {
+		spin_unlock(&clp->cl_lock);
+		ns = nfs4_alloc_stid(clp, stateid_slab);
+		if (ns == NULL)
+			return NULL;
+
+		spin_lock(&clp->cl_lock);
+		lst = find_lock_stateid(lo, fi);
+		if (likely(!lst)) {
+			lst = openlockstateid(ns);
+			init_lock_stateid(lst, lo, fi, inode, ost);
+			ns = NULL;
+			*new = true;
+		}
+	}
+	spin_unlock(&clp->cl_lock);
+	if (ns)
+		nfs4_put_stid(ns);
+	return lst;
+}
 
 static int
 check_lock_length(u64 offset, u64 length)
@@ -4783,7 +4810,11 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 	set_access(access, lock_stp);
 }
 
-static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
+static __be32
+lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
+			    struct nfs4_ol_stateid *ost,
+			    struct nfsd4_lock *lock,
+			    struct nfs4_ol_stateid **lst, bool *new)
 {
 	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
@@ -4807,14 +4838,10 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 			return nfserr_bad_seqid;
 	}
 
-	*lst = find_lock_stateid(lo, fi);
+	*lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
 	if (*lst == NULL) {
-		*lst = alloc_init_lock_stateid(lo, fi, inode, ost);
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

