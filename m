Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:53708 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbaDRSpc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:32 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so1922456iec.21
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 17/70] NFSd: Lock owners are not per open stateid
Date: Fri, 18 Apr 2014 14:44:11 -0400
Message-Id: <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the NFSv4 spec, lock stateids are per-file objects. Lockowners are not.
This patch replaces the current list of lock owners in the open statids
with a list of lock stateids.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 48 +++++++++++++++++++++++++++++++-----------------
 fs/nfsd/state.h     |  3 +--
 2 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5105dbc76888..8a12d59c8f36 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -704,10 +704,11 @@ static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
-static void release_lock_stateid(struct nfs4_ol_stateid *stp)
+static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct file *file;
 
+	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
 	file = find_any_file(stp->st_file);
@@ -724,12 +725,11 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 	struct nfs4_ol_stateid *stp;
 
 	list_del(&lo->lo_owner.so_strhash);
-	list_del(&lo->lo_perstateid);
 	list_del(&lo->lo_owner_ino_hash);
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		release_lock_stateid(stp);
+		__release_lock_stateid(stp);
 	}
 }
 
@@ -745,22 +745,36 @@ static void release_lockowner(struct nfs4_lockowner *lo)
 	nfs4_free_lockowner(lo);
 }
 
-static void
-release_stateid_lockowners(struct nfs4_ol_stateid *open_stp)
+static void release_lockowner_if_empty(struct nfs4_lockowner *lo)
+{
+	if (list_empty(&lo->lo_owner.so_stateids))
+		release_lockowner(lo);
+}
+
+static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_lockowner *lo;
 
-	while (!list_empty(&open_stp->st_lockowners)) {
-		lo = list_entry(open_stp->st_lockowners.next,
-				struct nfs4_lockowner, lo_perstateid);
-		release_lockowner(lo);
+	lo = lockowner(stp->st_stateowner);
+	__release_lock_stateid(stp);
+	release_lockowner_if_empty(lo);
+}
+
+static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp)
+{
+	struct nfs4_ol_stateid *stp;
+
+	while (!list_empty(&open_stp->st_locks)) {
+		stp = list_entry(open_stp->st_locks.next,
+				struct nfs4_ol_stateid, st_locks);
+		release_lock_stateid(stp);
 	}
 }
 
 static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_generic_stateid(stp);
-	release_stateid_lockowners(stp);
+	release_open_stateid_locks(stp);
 	close_generic_stateid(stp);
 }
 
@@ -2716,7 +2730,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	struct nfs4_openowner *oo = open->op_openowner;
 
 	stp->st_stid.sc_type = NFS4_OPEN_STID;
-	INIT_LIST_HEAD(&stp->st_lockowners);
+	INIT_LIST_HEAD(&stp->st_locks);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
@@ -4327,7 +4341,6 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	list_add(&lo->lo_owner_ino_hash, &nn->lockowner_ino_hashtbl[inohash]);
-	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
 }
 
 /*
@@ -4371,6 +4384,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
+	list_add(&stp->st_locks, &open_stp->st_locks);
 	spin_lock(&fp->fi_lock);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	spin_unlock(&fp->fi_lock);
@@ -4962,18 +4976,18 @@ static void nfsd_print_count(struct nfs4_client *clp, unsigned int count,
 	printk(KERN_INFO "NFS Client: %s has %u %s\n", buf, count, type);
 }
 
-static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max, void (*func)(struct nfs4_lockowner *))
+static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max, void (*func)(struct nfs4_ol_stateid *))
 {
 	struct nfs4_openowner *oop;
-	struct nfs4_lockowner *lop, *lo_next;
 	struct nfs4_ol_stateid *stp, *st_next;
+	struct nfs4_ol_stateid *lst, *lst_next;
 	u64 count = 0;
 
 	list_for_each_entry(oop, &clp->cl_openowners, oo_perclient) {
 		list_for_each_entry_safe(stp, st_next, &oop->oo_owner.so_stateids, st_perstateowner) {
-			list_for_each_entry_safe(lop, lo_next, &stp->st_lockowners, lo_perstateid) {
+			list_for_each_entry_safe(lst, lst_next, &stp->st_locks, st_locks) {
 				if (func)
-					func(lop);
+					func(lst);
 				if (++count == max)
 					return count;
 			}
@@ -4985,7 +4999,7 @@ static u64 nfsd_foreach_client_lock(struct nfs4_client *clp, u64 max, void (*fun
 
 u64 nfsd_forget_client_locks(struct nfs4_client *clp, u64 max)
 {
-	return nfsd_foreach_client_lock(clp, max, release_lockowner);
+	return nfsd_foreach_client_lock(clp, max, release_lock_stateid);
 }
 
 u64 nfsd_print_client_locks(struct nfs4_client *clp, u64 max)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 004733885cca..51df8df04d6a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -367,7 +367,6 @@ struct nfs4_openowner {
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
 	struct list_head	lo_owner_ino_hash; /* hash by owner,file */
-	struct list_head        lo_perstateid;
 	struct list_head	lo_list; /* for temporary uses */
 };
 
@@ -410,7 +409,7 @@ struct nfs4_ol_stateid {
 	struct nfs4_stid    st_stid; /* must be first field */
 	struct list_head              st_perfile;
 	struct list_head              st_perstateowner;
-	struct list_head              st_lockowners;
+	struct list_head              st_locks;
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
 	unsigned long                 st_access_bmap;
-- 
1.9.0

