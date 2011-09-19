Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34282 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698Ab1ISNPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 09:15:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: simplify free_stateid
Date: Mon, 19 Sep 2011 09:15:41 -0400
Message-Id: <1316438143-1057-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20110919131415.GB32498@fieldses.org>
References: <20110919131415.GB32498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We no longer need is_deleg_stateid, for example.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   66 +++++++++++---------------------------------------
 1 files changed, 15 insertions(+), 51 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a174841..fdd03f6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1098,16 +1098,6 @@ static struct nfs4_stid *find_stateid(stateid_t *t)
 	return NULL;
 }
 
-static struct nfs4_ol_stateid *find_ol_stateid(stateid_t *t)
-{
-	struct nfs4_stid *s;
-
-	s = find_stateid(t);
-	if (!s)
-		return NULL;
-	return openlockstateid(s);
-}
-
 static struct nfs4_stid *find_stateid_by_type(stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
@@ -3251,11 +3241,6 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_sess
 	return nfserr_old_stateid;
 }
 
-static int is_delegation_stateid(stateid_t *stateid)
-{
-	return stateid->si_fileid == 0;
-}
-
 __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 {
 	struct nfs4_stid *s;
@@ -3353,16 +3338,6 @@ out:
 }
 
 static __be32
-nfsd4_free_delegation_stateid(stateid_t *stateid)
-{
-	struct nfs4_delegation *dp = find_deleg_stateid(stateid);
-	if (dp)
-		return nfserr_locks_held;
-
-	return nfserr_bad_stateid;
-}
-
-static __be32
 nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	if (check_for_locks(stp->st_file, lockowner(stp->st_stateowner)))
@@ -3382,40 +3357,32 @@ nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return nfs_ok;
 }
 
-/*
- * Free a state id
- */
 __be32
 nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   struct nfsd4_free_stateid *free_stateid)
 {
 	stateid_t *stateid = &free_stateid->fr_stateid;
-	struct nfs4_ol_stateid *stp;
-	__be32 ret;
+	struct nfs4_stid *s;
+	__be32 ret = nfserr_bad_stateid;
 
 	nfs4_lock_state();
-	if (is_delegation_stateid(stateid)) {
-		ret = nfsd4_free_delegation_stateid(stateid);
-		goto out;
-	}
-
-	stp = find_ol_stateid(stateid);
-	if (!stp) {
-		ret = nfserr_bad_stateid;
-		goto out;
-	}
-	ret = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, 1);
-	if (ret)
+	s = find_stateid(stateid);
+	if (!s)
 		goto out;
-
-	if (stp->st_stid.sc_type == NFS4_OPEN_STID) {
+	switch (s->sc_type) {
+	case NFS4_DELEG_STID:
 		ret = nfserr_locks_held;
 		goto out;
-	} else {
-		ret = nfsd4_free_lock_stateid(stp);
-		goto out;
+	case NFS4_OPEN_STID:
+	case NFS4_LOCK_STID:
+		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
+		if (ret)
+			goto out;
+		if (s->sc_type == NFS4_LOCK_STID)
+			ret = nfsd4_free_lock_stateid(openlockstateid(s));
+		else
+			ret = nfserr_locks_held;
 	}
-
 out:
 	nfs4_unlock_state();
 	return ret;
@@ -3698,9 +3665,6 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfserr_stale_stateid;
 	if (STALE_STATEID(stateid))
 		goto out;
-	status = nfserr_bad_stateid;
-	if (!is_delegation_stateid(stateid))
-		goto out;
 	status = nfserr_expired;
 	dp = find_deleg_stateid(stateid);
 	if (!dp)
-- 
1.7.4.1

