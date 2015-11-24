Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43505 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753872AbbKXRSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 12:18:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd: minor consolidation of mach_cred handling code
Date: Tue, 24 Nov 2015 12:18:15 -0500
Message-Id: <1448385497-23737-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1448385497-23737-1-git-send-email-bfields@redhat.com>
References: <1448385497-23737-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Minor cleanup, no change in functionality.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index db53df069069..5b1be1ab700b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2374,10 +2374,17 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	if (exid->flags & ~EXCHGID4_FLAG_MASK_A)
 		return nfserr_inval;
 
+	new = create_client(exid->clname, rqstp, &verf);
+	if (new == NULL)
+		return nfserr_jukebox;
+
 	switch (exid->spa_how) {
 	case SP4_MACH_CRED:
-		if (!svc_rqst_integrity_protected(rqstp))
-			return nfserr_inval;
+		if (!svc_rqst_integrity_protected(rqstp)) {
+			status = nfserr_inval;
+			goto out_nolock;
+		}
+		new->cl_mach_cred = true;
 	case SP4_NONE:
 		break;
 	default:				/* checked by xdr code */
@@ -2386,10 +2393,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_encr_alg_unsupp;
 	}
 
-	new = create_client(exid->clname, rqstp, &verf);
-	if (new == NULL)
-		return nfserr_jukebox;
-
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&exid->clname, nn);
@@ -2451,7 +2454,6 @@ out_new:
 			goto out;
 	}
 	new->cl_minorversion = cstate->minorversion;
-	new->cl_mach_cred = (exid->spa_how == SP4_MACH_CRED);
 
 	gen_clid(new, nn);
 	add_to_unconfirmed(new);
@@ -2469,6 +2471,7 @@ out_copy:
 
 out:
 	spin_unlock(&nn->client_lock);
+out_nolock:
 	if (new)
 		expire_client(new);
 	if (unconf)
-- 
2.5.0

