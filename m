Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57682 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932Ab0JUQUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 01/11] nfsd4: don't cache seq_misordered replies
Date: Thu, 21 Oct 2010 12:20:08 -0400
Message-Id: <1287678018-9266-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 02c23b7..7f12828 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1510,7 +1510,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
-			goto out_cache;
+			goto out;
 		}
 
 		cs_slot->sl_seqid++; /* from 0 to 1 */
@@ -1549,7 +1549,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	       NFS4_MAX_SESSIONID_LEN);
 	cr_ses->seqid = cs_slot->sl_seqid;
 
-out_cache:
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
 out:
-- 
1.7.1

