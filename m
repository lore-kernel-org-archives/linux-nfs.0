Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50131 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935407Ab3DIX6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/10] nfsd4: cleanup check_forechannel_attrs
Date: Tue,  9 Apr 2013 19:58:11 -0400
Message-Id: <1365551896-6936-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Pass this struct by reference, not by value, and return an error instead
of a boolean to allow for future additions.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7d2e3b5..f1262f7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1803,10 +1803,13 @@ nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
 				/* seqid, slotID, slotID, slotID, status */ \
 			5 ) * sizeof(__be32))
 
-static bool check_forechannel_attrs(struct nfsd4_channel_attrs fchannel)
+static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca)
 {
-	return fchannel.maxreq_sz < NFSD_MIN_REQ_HDR_SEQ_SZ
-		|| fchannel.maxresp_sz < NFSD_MIN_RESP_HDR_SEQ_SZ;
+	if (ca->maxreq_sz < NFSD_MIN_REQ_HDR_SEQ_SZ)
+		return nfserr_toosmall;
+	if (ca->maxresp_sz < NFSD_MIN_RESP_HDR_SEQ_SZ)
+		return nfserr_toosmall;
+	return nfs_ok;
 }
 
 __be32
@@ -1824,8 +1827,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
 		return nfserr_inval;
-	if (check_forechannel_attrs(cr_ses->fore_channel))
-		return nfserr_toosmall;
+	status = check_forechannel_attrs(&cr_ses->fore_channel);
+	if (status)
+		return status;
 	new = alloc_session(&cr_ses->fore_channel, nn);
 	if (!new)
 		return nfserr_jukebox;
-- 
1.7.9.5

