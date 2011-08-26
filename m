Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53247 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/15] nfsd4: consolidate lock & open stateid tables
Date: Fri, 26 Aug 2011 18:28:33 -0400
Message-Id: <1314397716-18602-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

There's no reason to have two separate hash tables for open and lock
stateid's.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   65 +++++++++++++-------------------------------------
 fs/nfsd/state.h     |    3 ++
 2 files changed, 20 insertions(+), 48 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc2f5d1..5111eb1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -61,7 +61,6 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
-static struct nfs4_stateid * search_for_stateid(stateid_t *stid);
 static struct nfs4_delegation * search_for_delegation(stateid_t *stid);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
@@ -2287,6 +2286,7 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perstateowner, &sop->so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
+	stp->st_type = NFS4_OPEN_STID;
 	stp->st_stateowner = sop;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
@@ -3217,7 +3217,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 		goto out;
 
 	status = nfserr_expired;
-	stp = search_for_stateid(stateid);
+	stp = find_stateid(stateid, 0);
 	if (!stp)
 		goto out;
 	status = nfserr_bad_stateid;
@@ -3355,7 +3355,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	stp = search_for_stateid(stateid);
+	stp = find_stateid(stateid, 0);
 	if (!stp) {
 		ret = nfserr_bad_stateid;
 		goto out;
@@ -3724,7 +3724,6 @@ lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
 
 static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
-static struct list_head lockstateid_hashtbl[STATEID_HASH_SIZE];
 
 static int
 same_stateid(stateid_t *id_one, stateid_t *id_two)
@@ -3734,50 +3733,21 @@ same_stateid(stateid_t *id_one, stateid_t *id_two)
 	return id_one->si_fileid == id_two->si_fileid;
 }
 
-static struct nfs4_stateid *
-find_stateid(stateid_t *stid, int flags)
+static struct nfs4_stateid *find_stateid(stateid_t *t, int flags)
 {
-	struct nfs4_stateid *local;
-	u32 st_id = stid->si_stateownerid;
-	u32 f_id = stid->si_fileid;
+	struct nfs4_stateid *s;
 	unsigned int hashval;
 
-	dprintk("NFSD: find_stateid flags 0x%x\n",flags);
-	if (flags & (LOCK_STATE | RD_STATE | WR_STATE)) {
-		hashval = stateid_hashval(st_id, f_id);
-		list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
-			if ((local->st_stateid.si_stateownerid == st_id) &&
-			    (local->st_stateid.si_fileid == f_id))
-				return local;
-		}
-	} 
-
-	if (flags & (OPEN_STATE | RD_STATE | WR_STATE)) {
-		hashval = stateid_hashval(st_id, f_id);
-		list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
-			if ((local->st_stateid.si_stateownerid == st_id) &&
-			    (local->st_stateid.si_fileid == f_id))
-				return local;
+	hashval = stateid_hashval(t->si_stateownerid, t->si_fileid);
+	list_for_each_entry(s, &stateid_hashtbl[hashval], st_hash) {
+		if (!same_stateid(&s->st_stateid, t))
+			continue;
+		if (flags & LOCK_STATE && s->st_type != NFS4_LOCK_STID)
+			return NULL;
+		if (flags & OPEN_STATE && s->st_type != NFS4_OPEN_STID)
+			return NULL;
+		return s;
 		}
-	}
-	return NULL;
-}
-
-static struct nfs4_stateid *
-search_for_stateid(stateid_t *stid)
-{
-	struct nfs4_stateid *local;
-	unsigned int hashval = stateid_hashval(stid->si_stateownerid, stid->si_fileid);
-
-	list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
-		if (same_stateid(&local->st_stateid, stid))
-			return local;
-	}
-
-	list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
-		if (same_stateid(&local->st_stateid, stid))
-			return local;
-	}
 	return NULL;
 }
 
@@ -3926,10 +3896,11 @@ alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struc
 	INIT_LIST_HEAD(&stp->st_perfile);
 	INIT_LIST_HEAD(&stp->st_perstateowner);
 	INIT_LIST_HEAD(&stp->st_lockowners); /* not used */
-	list_add(&stp->st_hash, &lockstateid_hashtbl[hashval]);
+	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &sop->so_stateids);
 	stp->st_stateowner = sop;
+	stp->st_type = NFS4_LOCK_STID;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
 	stp->st_stateid.si_boot = boot_time;
@@ -4502,10 +4473,8 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&open_ownerstr_hashtbl[i]);
 		INIT_LIST_HEAD(&open_ownerid_hashtbl[i]);
 	}
-	for (i = 0; i < STATEID_HASH_SIZE; i++) {
+	for (i = 0; i < STATEID_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&stateid_hashtbl[i]);
-		INIT_LIST_HEAD(&lockstateid_hashtbl[i]);
-	}
 	for (i = 0; i < LOCK_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&lock_ownerid_hashtbl[i]);
 		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4a69c89..fad30d8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -426,6 +426,9 @@ static inline struct file *find_any_file(struct nfs4_file *f)
 */
 
 struct nfs4_stateid {
+#define NFS4_OPEN_STID 1
+#define NFS4_LOCK_STID 2
+	char st_type;
 	struct list_head              st_hash; 
 	struct list_head              st_perfile;
 	struct list_head              st_perstateowner;
-- 
1.7.4.1

