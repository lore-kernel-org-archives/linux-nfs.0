Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41419 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055Ab2E3Sgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 14:36:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: remove some dprintk's and a comment
Date: Wed, 30 May 2012 14:36:26 -0400
Message-Id: <1338402988-17356-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1338402988-17356-1-git-send-email-bfields@redhat.com>
References: <1338402988-17356-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The comment is redundant, and if we really want dprintk's here they'd
probably be better in the common (check-slot_seqid) code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bcb4b50..c03c951 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1750,16 +1750,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		cs_slot = &conf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status == nfserr_replay_cache) {
-			dprintk("Got a create_session replay! seqid= %d\n",
-				cs_slot->sl_seqid);
-			/* Return the cached reply status */
 			status = nfsd4_replay_create_session(cr_ses, cs_slot);
 			goto out;
 		} else if (cr_ses->seqid != cs_slot->sl_seqid + 1) {
 			status = nfserr_seq_misordered;
-			dprintk("Sequence misordered!\n");
-			dprintk("Expected seqid= %d but got seqid= %d\n",
-				cs_slot->sl_seqid, cr_ses->seqid);
 			goto out;
 		}
 	} else if (unconf) {
@@ -1768,7 +1762,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = nfserr_clid_inuse;
 			goto out;
 		}
-
 		cs_slot = &unconf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status) {
@@ -1776,7 +1769,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = nfserr_seq_misordered;
 			goto out;
 		}
-
 		confirm_me = true;
 		conf = unconf;
 	} else {
-- 
1.7.10.2

