From: andros@netapp.com
Subject: [PATCH 4/5] nfsd41: replace nfserr_resource in pure nfs41 responses
Date: Thu, 27 Aug 2009 12:07:43 -0400
Message-ID: <1251389264-3009-5-git-send-email-andros@netapp.com>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>
 <1251389264-3009-2-git-send-email-andros@netapp.com>
 <1251389264-3009-3-git-send-email-andros@netapp.com>
 <1251389264-3009-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11161 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811AbZH0QH3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Aug 2009 12:07:29 -0400
In-Reply-To: <1251389264-3009-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfserr_resource is not a legal error for NFSv4.1. Replace it with
nfserr_serverfault for EXCHANGE_ID and CREATE_SESSION processing.

We will also need to map nfserr_resource to other errors in routines shared
by NFSv4.0 and NFSv4.1

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ada10ad..4695cec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -515,7 +515,7 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 		   struct nfsd4_create_session *cses)
 {
 	struct nfsd4_session *new, tmp;
-	int idx, status = nfserr_resource, slotsize;
+	int idx, status = nfserr_serverfault, slotsize;
 
 	memset(&tmp, 0, sizeof(tmp));
 
@@ -1278,7 +1278,7 @@ out_new:
 	/* Normal case */
 	new = create_client(exid->clname, dname);
 	if (new == NULL) {
-		status = nfserr_resource;
+		status = nfserr_serverfault;
 		goto out;
 	}
 
-- 
1.6.2.5

