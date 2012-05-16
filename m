Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44925 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933200Ab2EPMsn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/11] nfsd4: exchange_id cleanup: local shorthands for repeated tests
Date: Wed, 16 May 2012 08:48:33 -0400
Message-Id: <1337172519-17335-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 76459a7..e7c4b04 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1483,6 +1483,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
+	bool	update = exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A;
 
 	rpc_ntop(sa, addr_str, sizeof(addr_str));
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
@@ -1515,23 +1516,26 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_str(dname, strhashval);
 	if (conf) {
+		bool creds_match = same_creds(&conf->cl_cred, &rqstp->rq_cred);
+		bool verfs_match = same_verf(&verf, &conf->cl_verifier);
+
 		if (!clp_used_exchangeid(conf)) {
-			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+			if (update) {
 				status = nfserr_inval; /* buggy client */
 				goto out;
 			}
 		}
-		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
+		if (!creds_match) {
 			/* 18.35.4 case 9 */
-			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A)
+			if (update)
 				status = nfserr_perm;
 			else /* case 3 */
 				status = nfserr_clid_inuse;
 			goto out;
 		}
-		if (!same_verf(&verf, &conf->cl_verifier)) {
+		if (!verfs_match) {
 			/* 18.35.4 case 8 */
-			if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+			if (update) {
 				status = nfserr_not_same;
 				goto out;
 			}
@@ -1558,7 +1562,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	}
 
 	/* 18.35.4 case 7 */
-	if (exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A) {
+	if (update) {
 		status = nfserr_noent;
 		goto out;
 	}
-- 
1.7.9.5

