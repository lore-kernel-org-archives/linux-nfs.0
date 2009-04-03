From: andros@netapp.com
Subject: [PATCH 05/22] SQUASHME: nfsd41: use cstate session in nfs4svc_encode_compoundres
Date: Thu,  2 Apr 2009 20:19:46 -0400
Message-ID: <1238718003-8764-5-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755899AbZDCAU1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:27 -0400
In-Reply-To: <1238718003-8764-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review by Bruce:
squash into nfsd DRC logic

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 36469f5..0c924de 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3348,8 +3348,8 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 			resp->cstate.slot->sl_inuse = 0;
 		}
-		if (resp->cstate.slot->sl_session)
-			nfsd4_put_session(resp->cstate.slot->sl_session);
+		if (resp->cstate.session)
+			nfsd4_put_session(resp->cstate.session);
 	}
 #endif /* CONFIG_NFSD_V4_1 */
 	return 1;
-- 
1.5.4.3

