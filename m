Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34285 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064Ab1ISNPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 09:15:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd4: match close replays on stateid, not open owner id
Date: Mon, 19 Sep 2011 09:15:40 -0400
Message-Id: <1316438143-1057-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20110919131415.GB32498@fieldses.org>
References: <20110919131415.GB32498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Keep around an unhashed copy of the final stateid after the last close
using an openowner, and when identifying a replay, match against that
stateid instead of just against the open owner id.  Free it the next
time the seqid is bumped or the stateowner is destroyed.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   47 ++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4xdr.c   |    1 +
 fs/nfsd/state.h     |    3 +++
 3 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 59b70af..a174841 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -438,7 +438,6 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	close_generic_stateid(stp);
 	kmem_cache_free(stateid_slab, stp);
 }
 
@@ -450,6 +449,7 @@ static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 	file = find_any_file(stp->st_file);
 	if (file)
 		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
+	close_generic_stateid(stp);
 	free_generic_stateid(stp);
 }
 
@@ -485,10 +485,16 @@ release_stateid_lockowners(struct nfs4_ol_stateid *open_stp)
 	}
 }
 
-static void release_open_stateid(struct nfs4_ol_stateid *stp)
+static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_generic_stateid(stp);
 	release_stateid_lockowners(stp);
+	close_generic_stateid(stp);
+}
+
+static void release_open_stateid(struct nfs4_ol_stateid *stp)
+{
+	unhash_open_stateid(stp);
 	free_generic_stateid(stp);
 }
 
@@ -510,6 +516,8 @@ static void release_openowner(struct nfs4_openowner *oo)
 {
 	unhash_openowner(oo);
 	list_del(&oo->oo_close_lru);
+	if (oo->oo_last_closed_stid)
+		free_generic_stateid(oo->oo_last_closed_stid);
 	nfs4_free_openowner(oo);
 }
 
@@ -2324,6 +2332,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = 0;
 	oo->oo_time = 0;
+	oo->oo_last_closed_stid = NULL;
 	INIT_LIST_HEAD(&oo->oo_close_lru);
 	hash_openowner(oo, clp, strhashval);
 	return oo;
@@ -3120,12 +3129,14 @@ laundromat_main(struct work_struct *not_used)
 	queue_delayed_work(laundry_wq, &laundromat_work, t*HZ);
 }
 
-static struct nfs4_openowner * search_close_lru(u32 st_id)
+static struct nfs4_openowner * search_close_lru(stateid_t *s)
 {
 	struct nfs4_openowner *local;
+	struct nfs4_ol_stateid *os;
 
 	list_for_each_entry(local, &close_lru, oo_close_lru) {
-		if (local->oo_owner.so_id == st_id)
+		os = local->oo_last_closed_stid;
+		if (same_stateid(&os->st_stid.sc_stateid, s))
 			return local;
 	}
 	return NULL;
@@ -3589,6 +3600,27 @@ out:
 	return status;
 }
 
+void nfsd4_purge_closed_stateid(struct nfs4_stateowner *so)
+{
+	struct nfs4_openowner *oo;
+	struct nfs4_ol_stateid *s;
+
+	if (!so->so_is_open_owner)
+		return;
+	oo = openowner(so);
+	s = oo->oo_last_closed_stid;
+	if (!s)
+		return;
+	if (!(oo->oo_flags & NFS4_OO_PURGE_CLOSE)) {
+		/* Release the last_closed_stid on the next seqid bump: */
+		oo->oo_flags |= NFS4_OO_PURGE_CLOSE;
+		return;
+	}
+	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
+	free_generic_stateid(oo->oo_last_closed_stid);
+	oo->oo_last_closed_stid = NULL;
+}
+
 /*
  * nfs4_unlock_state() called after encode
  */
@@ -3613,7 +3645,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * Also, we should make sure this isn't just the result of
 		 * a replayed close:
 		 */
-		oo = search_close_lru(close->cl_stateid.si_stateownerid);
+		oo = search_close_lru(&close->cl_stateid);
 		/* It's not stale; let's assume it's expired: */
 		if (oo == NULL)
 			goto out;
@@ -3630,8 +3662,9 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
-	/* release_stateid() calls nfsd_close() if needed */
-	release_open_stateid(stp);
+	/* unhash_open_stateid() calls nfsd_close() if needed */
+	oo->oo_last_closed_stid = stp;
+	unhash_open_stateid(stp);
 
 	/* place unused nfs4_stateowners on so_close_lru list to be
 	 * released by the laundromat service after the lease period
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f4116cf..7bd57c2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1636,6 +1636,7 @@ static void encode_seqid_op_tail(struct nfsd4_compoundres *resp, __be32 *save, _
 			  (char *)resp->p - (char *)save;
 		memcpy(stateowner->so_replay.rp_buf, save,
 			stateowner->so_replay.rp_buflen);
+		nfsd4_purge_closed_stateid(stateowner);
 	}
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index a8324b8..e807abb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -370,8 +370,10 @@ struct nfs4_openowner {
 	struct nfs4_stateowner	oo_owner; /* must be first field */
 	struct list_head        oo_perclient;
 	struct list_head	oo_close_lru; /* tail queue */
+	struct nfs4_ol_stateid *oo_last_closed_stid;
 	time_t			oo_time; /* time of placement on so_close_lru */
 #define NFS4_OO_CONFIRMED   1
+#define NFS4_OO_PURGE_CLOSE 2
 	unsigned char		oo_flags;
 };
 
@@ -514,5 +516,6 @@ extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void release_session_client(struct nfsd4_session *);
 extern __be32 nfs4_validate_stateid(stateid_t *, bool);
+extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
 #endif   /* NFSD4_STATE_H */
-- 
1.7.4.1

