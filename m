From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 18/21] SQUASHME: nfsd41: calculate HAS_SESSION in nfs4_preprocess_stateid_op
Date: Fri,  3 Apr 2009 01:38:51 +0300
Message-ID: <1238711931-22583-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:19236 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764792AbZDBWi5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:57 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use nfsd4_has_session(cstate) in nfs4_preprocess_stateid_op rather
tahn passing it in.

squash into "nfsd41: stateid handling"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c  |   15 +++------------
 fs/nfsd/nfs4state.c |    3 +++
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index eeed38d..d39af3d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -535,7 +535,6 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_read *read)
 {
 	__be32 status;
-	int flags = RD_STATE;
 
 	/* no need to check permission - this will be done in nfsd_read() */
 
@@ -543,12 +542,10 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
 	nfs4_lock_state();
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(cstate, &read->rd_stateid,
-						 flags, &read->rd_filp))) {
+						 RD_STATE, &read->rd_filp))) {
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
@@ -677,14 +674,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_setattr *setattr)
 {
 	__be32 status = nfs_ok;
-	int flags = WR_STATE;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
 		nfs4_lock_state();
 		status = nfs4_preprocess_stateid_op(cstate,
-			&setattr->sa_stateid, flags, NULL);
+			&setattr->sa_stateid, WR_STATE, NULL);
 		nfs4_unlock_state();
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
@@ -716,17 +710,14 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	u32 *p;
 	__be32 status = nfs_ok;
 	unsigned long cnt;
-	int flags = WR_STATE;
 
 	/* no need to check permission - this will be done in nfsd_write() */
 
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	if (nfsd4_has_session(cstate))
-		flags |= HAS_SESSION;
 	nfs4_lock_state();
-	status = nfs4_preprocess_stateid_op(cstate, stateid, flags, &filp);
+	status = nfs4_preprocess_stateid_op(cstate, stateid, WR_STATE, &filp);
 	if (filp)
 		get_file(filp);
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f8c0172..0bdbff4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2889,6 +2889,9 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	if (grace_disallows_io(ino))
 		return nfserr_grace;
 
+	if (nfsd4_has_session(cstate))
+		flags |= HAS_SESSION;
+
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(current_fh, stateid, flags);
 
-- 
1.6.2.1

