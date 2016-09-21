Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36768 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758713AbcIUSDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Sep 2016 14:03:49 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd4: setclientid_confirm with unmatched verifier should fail
Date: Wed, 21 Sep 2016 14:03:45 -0400
Message-Id: <1474481025-23702-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1474481025-23702-1-git-send-email-bfields@redhat.com>
References: <1474481025-23702-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

A setclientid_confirm with (clientid, verifier) both matching an
existing confirmed record is assumed to be a replay, but if the verifier
doesn't match, it shouldn't be.

This would be a very rare case, except that clients following
https://tools.ietf.org/html/rfc7931#section-5.8 may depend on the
failure.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a204d7e109d4..4b657337cbcd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3224,9 +3224,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		goto out;
 	/* cases below refer to rfc 3530 section 14.2.34: */
 	if (!unconf || !same_verf(&confirm, &unconf->cl_confirm)) {
-		if (conf && !unconf) /* case 2: probable retransmit */
+		if (conf && same_verf(&confirm, &conf->cl_confirm)) {
+			/* case 2: probable retransmit */
 			status = nfs_ok;
-		else /* case 4: client hasn't noticed we rebooted yet? */
+		} else /* case 4: client hasn't noticed we rebooted yet? */
 			status = nfserr_stale_clientid;
 		goto out;
 	}
-- 
2.7.4

