Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44919 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933342Ab2EPMsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/11] nfsd4: exchange_id: check creds before killing confirmed client
Date: Wed, 16 May 2012 08:48:31 -0400
Message-Id: <1337172519-17335-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We mustn't allow a client to destroy another client with established
state unless it has the right credential.

And some minor cleanup.

(Note: our comparison of credentials is actually pretty bogus currently;
that will need to be fixed in another patch.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b7b884..9d77181 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1519,6 +1519,14 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			status = nfserr_clid_inuse; /* XXX: ? */
 			goto out;
 		}
+		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
+			/* 18.35.4 case 9 */
+			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A)
+				status = nfserr_perm;
+			else /* case 3 */
+				status = nfserr_clid_inuse;
+			goto out;
+		}
 		if (!same_verf(&verf, &conf->cl_verifier)) {
 			/* 18.35.4 case 8 */
 			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
@@ -1529,15 +1537,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			expire_client(conf);
 			goto out_new;
 		}
-		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
-			/* 18.35.4 case 9 */
-			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
-				status = nfserr_perm;
-				goto out;
-			}
-			expire_client(conf);
-			goto out_new;
-		}
 		/*
 		 * Set bit when the owner id and verifier map to an already
 		 * confirmed client id (18.35.3).
-- 
1.7.9.5

