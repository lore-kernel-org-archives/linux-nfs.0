Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43325 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab2JARqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/8] nfsd4: reject bad forechannel attrs earlier
Date: Mon,  1 Oct 2012 13:46:45 -0400
Message-Id: <1349113612-30374-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This could simplify the logic a little later.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5507842..64938ca 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1771,6 +1771,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
 		return nfserr_inval;
+	if (check_forechannel_attrs(cr_ses->fore_channel))
+		return nfserr_toosmall;
 
 	nfs4_lock_state();
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true);
@@ -1811,10 +1813,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->flags &= ~SESSION4_PERSIST;
 	cr_ses->flags &= ~SESSION4_RDMA;
 
-	status = nfserr_toosmall;
-	if (check_forechannel_attrs(cr_ses->fore_channel))
-		goto out;
-
 	status = nfserr_jukebox;
 	new = alloc_init_session(rqstp, conf, cr_ses);
 	if (!new)
-- 
1.7.9.5

