From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 030/100] nfsd4: remove unnecessary cl_verifier check from setclientid_confirm
Date: Fri, 25 Jan 2008 18:16:10 -0500
Message-ID: <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47368 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756214AbYAYXRb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:31 -0500
In-Reply-To: <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Again, the only way conf and unconf can have the same clientid is if
they were created in the "probable callback update" case of setclientid,
in which case we already know that the cl_verifier fields must agree.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d026c24..c6c270b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -837,7 +837,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	 */
 	if ((conf && unconf) && 
 	    (same_verf(&unconf->cl_confirm, &confirm)) &&
-	    (same_verf(&conf->cl_verifier, &unconf->cl_verifier)) &&
 	    (!same_verf(&conf->cl_confirm, &unconf->cl_confirm))) {
 		/*
 		 * RFC 3530 14.2.34 CASE 1:
@@ -855,9 +854,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			status = nfs_ok;
 
 		}
-	} else if ((conf && !unconf) ||
-	    ((conf && unconf) && 
-	     !same_verf(&conf->cl_verifier, &unconf->cl_verifier)) {
+	} else if (conf && !unconf) {
 		/*
 		 * RFC 3530 14.2.34 CASE 2:
 		 * probable retransmitted request; play it safe and
-- 
1.5.4.rc2.60.gb2e62

