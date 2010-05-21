From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/2] nfsd4: fix max_ops session negotiation
Date: Fri, 21 May 2010 19:33:07 -0400
Message-ID: <1274484787-15176-2-git-send-email-bfields@citi.umich.edu>
References: <1274484787-15176-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35359 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754616Ab0EUXdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 May 2010 19:33:08 -0400
In-Reply-To: <1274484787-15176-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We shouldn't accept the client's (possibly lower) max_ops if we don't
actually intend to enforce it; according to the spec:

	For the fore channel, the server MAY change the requested value.
	After the session is created, if a requester sends a COMPOUND or
	CB_COMPOUND with more operations than ca_maxoperations, the
	replier MUST return NFS4ERR_TOO_MANY_OPS.

Reported-by: Michael Groshans <groshans@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1176708..0d08b0c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -485,9 +485,7 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 		fchan->maxresp_sz = maxcount;
 	session_fchan->maxresp_sz = fchan->maxresp_sz;
 
-	/* Use the client's maxops if possible */
-	if (fchan->maxops > NFSD_MAX_OPS_PER_COMPOUND)
-		fchan->maxops = NFSD_MAX_OPS_PER_COMPOUND;
+	fchan->maxops = NFSD_MAX_OPS_PER_COMPOUND;
 	session_fchan->maxops = fchan->maxops;
 
 	/* FIXME: Error means no more DRC pages so the server should
-- 
1.7.0.4

