Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60196 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932197Ab1INLp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 24/25] nfsd4: use deleg changes to cleanup preprocess_stateid_op
Date: Wed, 14 Sep 2011 07:45:20 -0400
Message-Id: <1316000721-3289-25-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 30387f3..ea338d0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3290,6 +3290,7 @@ __be32
 nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			   stateid_t *stateid, int flags, struct file **filpp)
 {
+	struct nfs4_stid *s;
 	struct nfs4_ol_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	struct svc_fh *current_fh = &cstate->current_fh;
@@ -3314,13 +3315,14 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	 * but that we can't find, is expired:
 	 */
 	status = nfserr_expired;
-	if (is_delegation_stateid(stateid)) {
-		dp = find_deleg_stateid(stateid);
-		if (!dp)
-			goto out;
-		status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
-		if (status)
-			goto out;
+	s = find_stateid(stateid);
+	if (!s)
+		goto out;
+	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
+	if (status)
+		goto out;
+	if (s->sc_type == NFS4_DELEG_STID) {
+		dp = delegstateid(s);
 		status = nfs4_check_delegmode(dp, flags);
 		if (status)
 			goto out;
@@ -3330,19 +3332,13 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			BUG_ON(!*filpp);
 		}
 	} else { /* open or lock stateid */
-		stp = find_ol_stateid(stateid);
-		if (!stp)
-			goto out;
+		stp = openlockstateid(s);
 		status = nfserr_bad_stateid;
 		if (nfs4_check_fh(current_fh, stp))
 			goto out;
 		if (stp->st_stateowner->so_is_open_owner
 		    && !openowner(stp->st_stateowner)->oo_confirmed)
 			goto out;
-		status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid,
-						  nfsd4_has_session(cstate));
-		if (status)
-			goto out;
 		status = nfs4_check_openmode(stp, flags);
 		if (status)
 			goto out;
-- 
1.7.4.1

