Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44921 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933378Ab2EPMsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/11] nfsd4: allow an EXCHANGE_ID to kill a 4.0 client
Date: Wed, 16 May 2012 08:48:32 -0400
Message-Id: <1337172519-17335-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Following rfc 5661 section 2.4.1, we can permit a 4.1 client to remove
an established 4.0 client's state.

(But we don't allow updates.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9d77181..76459a7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1516,8 +1516,10 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	conf = find_confirmed_client_by_str(dname, strhashval);
 	if (conf) {
 		if (!clp_used_exchangeid(conf)) {
-			status = nfserr_clid_inuse; /* XXX: ? */
-			goto out;
+			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+				status = nfserr_inval; /* buggy client */
+				goto out;
+			}
 		}
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
 			/* 18.35.4 case 9 */
@@ -1537,6 +1539,10 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			expire_client(conf);
 			goto out_new;
 		}
+		if (!clp_used_exchangeid(conf)) {
+			status = nfserr_inval;
+			goto out;
+		}
 		/*
 		 * Set bit when the owner id and verifier map to an already
 		 * confirmed client id (18.35.3).
-- 
1.7.9.5

