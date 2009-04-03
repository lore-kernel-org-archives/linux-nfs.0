From: andros@netapp.com
Subject: [PATCH 13/22] SQUASHME nfsd41 replace nfsd4_set_cache_entry
Date: Thu,  2 Apr 2009 20:19:54 -0400
Message-ID: <1238718003-8764-13-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
 <1238718003-8764-9-git-send-email-andros@netapp.com>
 <1238718003-8764-10-git-send-email-andros@netapp.com>
 <1238718003-8764-11-git-send-email-andros@netapp.com>
 <1238718003-8764-12-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756843AbZDCAUe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:34 -0400
In-Reply-To: <1238718003-8764-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review by Bruce:
squash into nfsd DRC logic

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0c924de..8dfa14b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3344,7 +3344,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 				!nfsd4_no_page_in_cache(resp)) {
 			iov->iov_len = resp->cstate.iovlen;
 		} else {
-			nfsd4_set_cache_entry(resp);
+			nfsd4_store_cache_entry(resp);
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 			resp->cstate.slot->sl_inuse = 0;
 		}
-- 
1.5.4.3

