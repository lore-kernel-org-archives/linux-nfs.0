From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/6] nfsd4: translate memory errors to delay, not serverfault
Date: Thu, 24 Jun 2010 12:29:06 -0400
Message-ID: <1277396950-18298-3-git-send-email-bfields@citi.umich.edu>
References: <1277396950-18298-1-git-send-email-bfields@citi.umich.edu>
 <1277396950-18298-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52616 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756050Ab0FXQ3K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jun 2010 12:29:10 -0400
In-Reply-To: <1277396950-18298-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server is out of memory is better for clients to back off and
retry than to just error out.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5a69ee6..603076f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -457,7 +457,7 @@ static int set_forechannel_drc_size(struct nfsd4_channel_attrs *fchan)
 	spin_unlock(&nfsd_drc_lock);
 
 	if (fchan->maxreqs == 0)
-		return nfserr_serverfault;
+		return nfserr_jukebox;
 
 	fchan->maxresp_cached = size + NFSD_MIN_HDR_SEQ_SZ;
 	return 0;
@@ -542,7 +542,7 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot)
 		     + sizeof(struct nfsd4_session) > PAGE_SIZE);
 
-	status = nfserr_serverfault;
+	status = nfserr_jukebox;
 	/* allocate struct nfsd4_session and slot table pointers in one piece */
 	slotsize = tmp.se_fchannel.maxreqs * sizeof(struct nfsd4_slot *);
 	new = kzalloc(sizeof(*new) + slotsize, GFP_KERNEL);
@@ -1219,7 +1219,7 @@ out_new:
 	/* Normal case */
 	new = create_client(exid->clname, dname, rqstp, &verf);
 	if (new == NULL) {
-		status = nfserr_serverfault;
+		status = nfserr_jukebox;
 		goto out;
 	}
 
-- 
1.7.0.4

