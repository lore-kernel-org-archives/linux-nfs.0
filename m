From: andros@netapp.com
Subject: [PATCH 01/30] nfsd41: create_session check replay first
Date: Mon,  8 Jun 2009 14:20:42 -0400
Message-ID: <1244485271-7461-2-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24915 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751292AbZFHSVO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:14 -0400
In-Reply-To: <1244485271-7461-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replay processing needs to preceed other error processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3b711f5..e26e2b7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1369,12 +1369,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 		conf->cl_slot.sl_seqid++;
 	} else if (unconf) {
-		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
-		    (ip_addr != unconf->cl_addr)) {
-			status = nfserr_clid_inuse;
-			goto out;
-		}
-
 		slot = &unconf->cl_slot;
 		status = check_slot_seqid(cr_ses->seqid, slot);
 		if (status) {
@@ -1383,6 +1377,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out;
 		}
 
+		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
+		    (ip_addr != unconf->cl_addr)) {
+			status = nfserr_clid_inuse;
+			goto out;
+		}
+
 		slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
 
-- 
1.5.4.3

