From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 8/8] nfsd41: cstate->session can NULL in nfsd4_destroy_session
Date: Wed,  5 May 2010 01:45:07 +0300
Message-ID: <1273013107-32604-1-git-send-email-bhalevy@panasas.com>
References: <4BE0A1AE.4040905@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60434 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934370Ab0EDWpJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 18:45:09 -0400
In-Reply-To: <4BE0A1AE.4040905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If DESTROY_SESSION arrives on a singleton compound that has no SEQUENCE
operation cstate->session is NULL.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3b46994..8da730f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1394,8 +1394,9 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	 * - Do we need to clear any callback info from previous session?
 	 */
 
-	if (!memcmp(&sessionid->sessionid, &cstate->session->se_sessionid,
-					sizeof(struct nfs4_sessionid))) {
+	if (cstate->session &&
+	    !memcmp(&sessionid->sessionid, &cstate->session->se_sessionid,
+		    sizeof(struct nfs4_sessionid))) {
 		if (!nfsd4_last_compound_op(r))
 			return nfserr_not_only_op;
 	}
-- 
1.6.5.1

