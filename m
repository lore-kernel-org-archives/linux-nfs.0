Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44927 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933387Ab2EPMsn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/11] nfsd4: rearrange exchange_id logic to simplify
Date: Wed, 16 May 2012 08:48:35 -0400
Message-Id: <1337172519-17335-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Minor cleanup: it's simpler to have separate code paths for the update
and non-update cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1239ff4..0c553af 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1520,36 +1520,36 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
 		bool verfs_match = same_verf(&verf, &conf->cl_verifier);
 
-		if (!clp_used_exchangeid(conf)) {
-			if (update) { /* buggy client */
+		if (update) {
+			if (!clp_used_exchangeid(conf)) { /* buggy client */
 				status = nfserr_inval;
 				goto out;
 			}
-		}
-		if (!creds_match) { /* case 9 */
-			if (update)
+			if (!creds_match) { /* case 9 */
 				status = nfserr_perm;
-			else /* case 3 */
-				status = nfserr_clid_inuse;
-			goto out;
-		}
-		if (!verfs_match) { /* case 8 */
-			if (update) {
+				goto out;
+			}
+			if (!verfs_match) { /* case 8 */
 				status = nfserr_not_same;
 				goto out;
 			}
-			/* case 5, client reboot */
-			expire_client(conf);
-			goto out_new;
+			/* case 6 */
+			exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
+			new = conf;
+			goto out_copy;
 		}
-		if (!clp_used_exchangeid(conf)) {
-			status = nfserr_inval;
+		if (!creds_match) { /* case 3 */
+			status = nfserr_clid_inuse;
 			goto out;
 		}
-		/* case 2 */
-		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
-		new = conf;
-		goto out_copy;
+		if (verfs_match) { /* case 2 */
+			exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
+			new = conf;
+			goto out_copy;
+		}
+		/* case 5, client reboot */
+		expire_client(conf);
+		goto out_new;
 	}
 
 	if (update) { /* case 7 */
-- 
1.7.9.5

