Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60173 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 13/25] nfsd4: rearrange to avoid a forward reference
Date: Wed, 14 Sep 2011 07:45:09 -0400
Message-Id: <1316000721-3289-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   53 +++++++++++++++++++++++++--------------------------
 1 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c28432a..f0eccc2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -60,7 +60,6 @@ static u64 current_sessionid = 1;
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
 /* forward declarations */
-static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * search_for_delegation(stateid_t *stid);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
@@ -1061,6 +1060,32 @@ static void gen_confirm(struct nfs4_client *clp)
 	*p++ = i++;
 }
 
+static int
+same_stateid(stateid_t *id_one, stateid_t *id_two)
+{
+	if (id_one->si_stateownerid != id_two->si_stateownerid)
+		return 0;
+	return id_one->si_fileid == id_two->si_fileid;
+}
+
+static struct nfs4_stateid *find_stateid(stateid_t *t, int flags)
+{
+	struct nfs4_stateid *s;
+	unsigned int hashval;
+
+	hashval = stateid_hashval(t->si_stateownerid, t->si_fileid);
+	list_for_each_entry(s, &stateid_hashtbl[hashval], st_hash) {
+		if (!same_stateid(&s->st_stateid, t))
+			continue;
+		if (flags & LOCK_STATE && s->st_type != NFS4_LOCK_STID)
+			return NULL;
+		if (flags & OPEN_STATE && s->st_type != NFS4_OPEN_STID)
+			return NULL;
+		return s;
+		}
+	return NULL;
+}
+
 static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 		struct svc_rqst *rqstp, nfs4_verifier *verf)
 {
@@ -3694,32 +3719,6 @@ lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
 static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
 
-static int
-same_stateid(stateid_t *id_one, stateid_t *id_two)
-{
-	if (id_one->si_stateownerid != id_two->si_stateownerid)
-		return 0;
-	return id_one->si_fileid == id_two->si_fileid;
-}
-
-static struct nfs4_stateid *find_stateid(stateid_t *t, int flags)
-{
-	struct nfs4_stateid *s;
-	unsigned int hashval;
-
-	hashval = stateid_hashval(t->si_stateownerid, t->si_fileid);
-	list_for_each_entry(s, &stateid_hashtbl[hashval], st_hash) {
-		if (!same_stateid(&s->st_stateid, t))
-			continue;
-		if (flags & LOCK_STATE && s->st_type != NFS4_LOCK_STID)
-			return NULL;
-		if (flags & OPEN_STATE && s->st_type != NFS4_OPEN_STID)
-			return NULL;
-		return s;
-		}
-	return NULL;
-}
-
 static struct nfs4_delegation *
 search_for_delegation(stateid_t *stid)
 {
-- 
1.7.4.1

