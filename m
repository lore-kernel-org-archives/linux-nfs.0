Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884Ab3CUO4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/9] nfsd4: STALE_STATEID cleanup
Date: Thu, 21 Mar 2013 10:56:13 -0400
Message-Id: <1363877780-28825-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c5af45d..cfd4430 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3278,16 +3278,6 @@ static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *s
 	return nfs_ok;
 }
 
-static int
-STALE_STATEID(stateid_t *stateid, struct nfsd_net *nn)
-{
-	if (stateid->si_opaque.so_clid.cl_boot == nn->boot_time)
-		return 0;
-	dprintk("NFSD: stale stateid " STATEID_FMT "!\n",
-		STATEID_VAL(stateid));
-	return 1;
-}
-
 static inline int
 access_permit_read(struct nfs4_ol_stateid *stp)
 {
@@ -3418,19 +3408,20 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
 				   struct nfsd_net *nn)
 {
 	struct nfs4_client *cl;
+	__be32 status;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
-	if (STALE_STATEID(stateid, nn))
+	status = lookup_clientid(&stateid->si_opaque.so_clid, sessions,
+							nn, &cl);
+	if (status == nfserr_stale_clientid)
 		return nfserr_stale_stateid;
-	cl = find_confirmed_client(&stateid->si_opaque.so_clid, sessions, nn);
-	if (!cl)
-		return nfserr_expired;
+	if (status)
+		return status;
 	*s = find_stateid_by_type(cl, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
 	return nfs_ok;
-
 }
 
 /*
-- 
1.7.9.5

