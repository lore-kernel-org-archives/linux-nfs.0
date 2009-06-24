From: andros@netapp.com
Subject: [PATCH 5/5] nfsd41: remove redundant forechannel max requests check
Date: Wed, 24 Jun 2009 15:37:49 -0400
Message-ID: <1245872278-18743-6-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758431AbZFXTiB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:01 -0400
In-Reply-To: <1245872278-18743-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This check is done in set_forechannel_maxreqs.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a0bd6da..dc91544 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -479,10 +479,6 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 		fchan->maxops = NFSD_MAX_OPS_PER_COMPOUND;
 	session_fchan->maxops = fchan->maxops;
 
-	/* try to use the client requested number of slots */
-	if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
-		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
-
 	/* FIXME: Error means no more DRC pages so the server should
 	 * recover pages from existing sessions. For now fail session
 	 * creation.
-- 
1.5.4.3

