Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912Ab1HZW2m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:28:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 13/15] nfsd4: simplify stateid generation code, fix wraparound
Date: Fri, 26 Aug 2011 18:28:34 -0400
Message-Id: <1314397716-18602-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1314397716-18602-1-git-send-email-bfields@redhat.com>
References: <1314397716-18602-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Follow the recommendation from rfc3530bis for stateid generation number
wraparound, simplify some code, and fix or remove incorrect comments.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   52 ++++++++++++++++++++++----------------------------
 fs/nfsd/state.h     |    3 ++
 2 files changed, 26 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5111eb1..dc08ca7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3170,6 +3170,12 @@ grace_disallows_io(struct inode *inode)
 	return locks_in_grace() && mandatory_lock(inode);
 }
 
+/* Returns true iff a is later than b: */
+static bool stateid_generation_after(stateid_t *a, stateid_t *b)
+{
+	return (s32)a->si_generation - (s32)b->si_generation > 0;
+}
+
 static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
 {
 	/*
@@ -3177,25 +3183,25 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_sess
 	 * when it is zero.
 	 */
 	if (has_session && in->si_generation == 0)
-		goto out;
+		return nfs_ok;
+
+	if (in->si_generation == ref->si_generation)
+		return nfs_ok;
 
 	/* If the client sends us a stateid from the future, it's buggy: */
-	if (in->si_generation > ref->si_generation)
+	if (stateid_generation_after(in, ref))
 		return nfserr_bad_stateid;
 	/*
-	 * The following, however, can happen.  For example, if the
-	 * client sends an open and some IO at the same time, the open
-	 * may bump si_generation while the IO is still in flight.
-	 * Thanks to hard links and renames, the client never knows what
-	 * file an open will affect.  So it could avoid that situation
-	 * only by serializing all opens and IO from the same open
-	 * owner.  To recover from the old_stateid error, the client
-	 * will just have to retry the IO:
+	 * However, we could see a stateid from the past, even from a
+	 * non-buggy client.  For example, if the client sends a lock
+	 * while some IO is outstanding, the lock may bump si_generation
+	 * while the IO is still in flight.  The client could avoid that
+	 * situation by waiting for responses on all the IO requests,
+	 * but better performance may result in retrying IO that
+	 * receives an old_stateid error if requests are rarely
+	 * reordered in flight:
 	 */
-	if (in->si_generation < ref->si_generation)
-		return nfserr_old_stateid;
-out:
-	return nfs_ok;
+	return nfserr_old_stateid;
 }
 
 static int is_delegation_stateid(stateid_t *stateid)
@@ -3360,16 +3366,9 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfserr_bad_stateid;
 		goto out;
 	}
-	if (stateid->si_generation != 0) {
-		if (stateid->si_generation < stp->st_stateid.si_generation) {
-			ret = nfserr_old_stateid;
-			goto out;
-		}
-		if (stateid->si_generation > stp->st_stateid.si_generation) {
-			ret = nfserr_bad_stateid;
-			goto out;
-		}
-	}
+	ret = check_stateid_generation(stateid, &stp->st_stateid, 1);
+	if (ret)
+		goto out;
 
 	if (is_open_stateid(stp)) {
 		ret = nfserr_locks_held;
@@ -3446,11 +3445,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		return nfserr_bad_stateid;
 	}
 
-	/*
-	*  We now validate the seqid and stateid generation numbers.
-	*  For the moment, we ignore the possibility of 
-	*  generation number wraparound.
-	*/
 	if (!nfsd4_has_session(cstate) && seqid != sop->so_seqid)
 		goto check_replay;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index fad30d8..9114a64 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -293,6 +293,9 @@ static inline void
 update_stateid(stateid_t *stateid)
 {
 	stateid->si_generation++;
+	/* Wraparound recommendation from 3530bis-13 9.1.3.2: */
+	if (stateid->si_generation == 0)
+		stateid->si_generation = 1;
 }
 
 /* A reasonable value for REPLAY_ISIZE was estimated as follows:  
-- 
1.7.4.1

