From: andros@netapp.com
Subject: [PATCH 04/22] SQUASHME: nfsd41: use cstate session in nfsd4_check_drc_limit
Date: Thu,  2 Apr 2009 20:19:45 -0400
Message-ID: <1238718003-8764-4-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755678AbZDCAU0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:26 -0400
In-Reply-To: <1238718003-8764-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review by Bruce
squash into  nfsd41: check encode size for sessions maxresponse cached

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0084459..36469f5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3189,7 +3189,7 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 	if (!nfsd4_has_session(&resp->cstate))
 		return status;
 
-	session = slot->sl_session;
+	session = resp->cstate.session;
 	if (session == NULL || slot->sl_cache_entry.ce_cachethis == 0)
 		return status;
 
-- 
1.5.4.3

