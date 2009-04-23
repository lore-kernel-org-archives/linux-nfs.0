From: andros@netapp.com
Subject: [PATCH 03/29] nfsd41: create_session check replay first
Date: Thu, 23 Apr 2009 12:42:42 -0400
Message-ID: <1240504988-9572-4-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51648 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbZDWQnN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:13 -0400
In-Reply-To: <1240504988-9572-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replay processing needs to preceed other error processing, in this case a
replay will always trigger nfserr_clid_inuse.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 279b47e..20485c5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1374,12 +1374,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
 		status = check_slot_seqid(cr_ses->seqid, slot);
 		if (status) {
@@ -1388,6 +1382,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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

