Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab3FZTVc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/7] nfsd4: do not throw away 4.1 lock state on last unlock
Date: Wed, 26 Jun 2013 15:21:26 -0400
Message-Id: <1372274488-4752-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This reverts commit eb2099f31b0f090684a64ef8df44a30ff7c45fc2 "nfsd4:
release lockowners on last unlock in 4.1 case".  Trond identified
language in rfc 5661 section 8.2.4 which forbids this behavior:

	Stateids associated with byte-range locks are an exception.
	They remain valid even if a LOCKU frees all remaining locks, so
	long as the open file with which they are associated remains
	open, unless the client frees the stateids via the FREE_STATEID
	operation.

And bakeathon 2013 testing found a 4.1 freebsd client was getting an
incorrect BAD_STATEID return from a FREE_STATEID in the above situation
and then failing.

The spec language honestly was probably a mistake but at this point with
implementations already following it we're probably stuck with that.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fcc0610..a7d8a11 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4514,7 +4514,6 @@ __be32
 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_locku *locku)
 {
-	struct nfs4_lockowner *lo;
 	struct nfs4_ol_stateid *stp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
@@ -4547,10 +4546,9 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_jukebox;
 		goto out;
 	}
-	lo = lockowner(stp->st_stateowner);
 	locks_init_lock(file_lock);
 	file_lock->fl_type = F_UNLCK;
-	file_lock->fl_owner = (fl_owner_t)lo;
+	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
@@ -4569,11 +4567,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
-	if (nfsd4_has_session(cstate) && !check_for_locks(stp->st_file, lo)) {
-		WARN_ON_ONCE(cstate->replay_owner);
-		release_lockowner(lo);
-	}
-
 out:
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
-- 
1.8.1.4

