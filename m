Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50144 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935566Ab3DIX6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:21 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/10] nfsd4: release lockowners on last unlock in 4.1 case
Date: Tue,  9 Apr 2013 19:58:09 -0400
Message-Id: <1365551896-6936-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the 4.1 case we're supposed to release lockowners as soon as they're
no longer used.

It would probably be more efficient to reference count them, but that's
slightly fiddly due to the need to have callbacks from locks.c to take
into account lock merging and splitting.

For most cases just scanning the inode's lock list on unlock for
matching locks will be sufficient.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 16db25d..ff1577d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4387,6 +4387,7 @@ __be32
 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_locku *locku)
 {
+	struct nfs4_lockowner *lo;
 	struct nfs4_ol_stateid *stp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
@@ -4419,9 +4420,10 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_jukebox;
 		goto out;
 	}
+	lo = lockowner(stp->st_stateowner);
 	locks_init_lock(file_lock);
 	file_lock->fl_type = F_UNLCK;
-	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
+	file_lock->fl_owner = (fl_owner_t)lo;
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
@@ -4440,6 +4442,11 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
+	if (nfsd4_has_session(cstate) && !check_for_locks(stp->st_file, lo)) {
+		WARN_ON_ONCE(cstate->replay_owner);
+		release_lockowner(lo);
+	}
+
 out:
 	nfsd4_bump_seqid(cstate, status);
 	if (!cstate->replay_owner)
-- 
1.7.9.5

