Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60175 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932140Ab1INLp2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 14/25] nfsd4: split up find_stateid
Date: Wed, 14 Sep 2011 07:45:10 -0400
Message-Id: <1316000721-3289-15-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Minor cleanup.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   34 +++++++++++++++++++++-------------
 1 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f0eccc2..aa088bc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1068,21 +1068,29 @@ same_stateid(stateid_t *id_one, stateid_t *id_two)
 	return id_one->si_fileid == id_two->si_fileid;
 }
 
-static struct nfs4_stateid *find_stateid(stateid_t *t, int flags)
+static struct nfs4_stateid *find_stateid(stateid_t *t)
 {
 	struct nfs4_stateid *s;
 	unsigned int hashval;
 
 	hashval = stateid_hashval(t->si_stateownerid, t->si_fileid);
-	list_for_each_entry(s, &stateid_hashtbl[hashval], st_hash) {
-		if (!same_stateid(&s->st_stateid, t))
-			continue;
-		if (flags & LOCK_STATE && s->st_type != NFS4_LOCK_STID)
-			return NULL;
-		if (flags & OPEN_STATE && s->st_type != NFS4_OPEN_STID)
-			return NULL;
+	list_for_each_entry(s, &stateid_hashtbl[hashval], st_hash)
+		if (same_stateid(&s->st_stateid, t))
+			return s;
+	return NULL;
+}
+
+static struct nfs4_stateid *find_stateid_by_type(stateid_t *t, int flags)
+{
+	struct nfs4_stateid *s;
+
+	s = find_stateid(t);
+	if (!s)
+		return NULL;
+	if (flags & LOCK_STATE && s->st_type == NFS4_LOCK_STID)
+		return s;
+	if (flags & OPEN_STATE && s->st_type == NFS4_OPEN_STID)
 		return s;
-		}
 	return NULL;
 }
 
@@ -3241,7 +3249,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 		goto out;
 
 	status = nfserr_expired;
-	stp = find_stateid(stateid, 0);
+	stp = find_stateid(stateid);
 	if (!stp)
 		goto out;
 	status = nfserr_bad_stateid;
@@ -3306,7 +3314,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			BUG_ON(!*filpp);
 		}
 	} else { /* open or lock stateid */
-		stp = find_stateid(stateid, flags);
+		stp = find_stateid(stateid);
 		if (!stp)
 			goto out;
 		status = nfserr_bad_stateid;
@@ -3381,7 +3389,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	stp = find_stateid(stateid, 0);
+	stp = find_stateid(stateid);
 	if (!stp) {
 		ret = nfserr_bad_stateid;
 		goto out;
@@ -3440,7 +3448,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	* the confirmed flag is incorrecly set, or the generation 
 	* number is incorrect.  
 	*/
-	*stpp = find_stateid(stateid, flags);
+	*stpp = find_stateid_by_type(stateid, flags);
 	if (*stpp == NULL)
 		return nfserr_expired;
 
-- 
1.7.4.1

