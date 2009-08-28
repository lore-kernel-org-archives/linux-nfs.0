From: andros@netapp.com
Subject: [PATCH 3/4] nfsd41: replace nfserr_resource in pure nfs41 responses
Date: Fri, 28 Aug 2009 08:45:03 -0400
Message-ID: <1251463504-3376-4-git-send-email-andros@netapp.com>
References: <1251463504-3376-1-git-send-email-andros@netapp.com>
 <1251463504-3376-2-git-send-email-andros@netapp.com>
 <1251463504-3376-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055AbZIAVCb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 17:02:31 -0400
In-Reply-To: <1251463504-3376-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfserr_resource is not a legal error for NFSv4.1. Replace it with
nfserr_serverfault for EXCHANGE_ID and CREATE_SESSION processing.

We will also need to map nfserr_resource to other errors in routines shared
by NFSv4.0 and NFSv4.1

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ec074e7..c9a45f4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -469,7 +469,7 @@ static int set_forechannel_drc_size(struct nfsd4_channel_attrs *fchan)
 	spin_unlock(&nfsd_drc_lock);
 
 	if (fchan->maxreqs == 0)
-		return nfserr_resource;
+		return nfserr_serverfault;
 
 	fchan->maxresp_cached = size + NFSD_MIN_HDR_SEQ_SZ;
 	return 0;
@@ -519,7 +519,7 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 		   struct nfsd4_create_session *cses)
 {
 	struct nfsd4_session *new, tmp;
-	int idx, status = nfserr_resource, slotsize;
+	int idx, status = nfserr_serverfault, slotsize;
 
 	memset(&tmp, 0, sizeof(tmp));
 
@@ -1282,7 +1282,7 @@ out_new:
 	/* Normal case */
 	new = create_client(exid->clname, dname);
 	if (new == NULL) {
-		status = nfserr_resource;
+		status = nfserr_serverfault;
 		goto out;
 	}
 
-- 
1.6.2.5

