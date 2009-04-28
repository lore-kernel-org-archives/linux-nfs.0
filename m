From: andros@netapp.com
Subject: [PATCH 06/31] nfsd41: create_session check replay first
Date: Tue, 28 Apr 2009 12:59:40 -0400
Message-ID: <1240938005-23778-6-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35461 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932747AbZD1RBp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:01:45 -0400
In-Reply-To: <1240938005-23778-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replay processing needs to preceed other error processing.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 142c460..de7cc51 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1373,12 +1373,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 		conf->cl_slot.sl_seqid++;
 	} else if (unconf) {
-		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
-		    (ip_addr != unconf->cl_addr)) {
-			status = nfserr_clid_inuse;
-			goto out_cache;
-		}
-
 		slot = &unconf->cl_slot;
 		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
 		if (status) {
@@ -1387,6 +1381,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out;
 		}
 
+		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
+		    (ip_addr != unconf->cl_addr)) {
+			status = nfserr_clid_inuse;
+			goto out_cache;
+		}
+
 		slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
 
-- 
1.5.4.3

