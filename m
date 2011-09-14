Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60157 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932197Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 04/25] nfsd4: eliminate impossible open replay case
Date: Wed, 14 Sep 2011 07:45:00 -0400
Message-Id: <1316000721-3289-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If open fails with any error other than nfserr_replay_me, then the main
nfsd4_proc_compound() loop continues unconditionally to
nfsd4_encode_operation(), which will always call encode_seqid_op_tail.
Thus the condition we check for here does not occur.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6cf729a..26b0c75 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2495,18 +2495,8 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		open->op_stateowner = NULL;
 		goto renew;
 	}
-	if (open->op_seqid == sop->so_seqid - 1) {
-		if (sop->so_replay.rp_buflen)
-			return nfserr_replay_me;
-		/* The original OPEN failed so spectacularly
-		 * that we don't even have replay data saved!
-		 * Therefore, we have no choice but to continue
-		 * processing this OPEN; presumably, we'll
-		 * fail again for the same reason.
-		 */
-		dprintk("nfsd4_process_open1: replay with no replay cache\n");
-		goto renew;
-	}
+	if (open->op_seqid == sop->so_seqid - 1)
+		return nfserr_replay_me;
 	if (open->op_seqid != sop->so_seqid)
 		return nfserr_bad_seqid;
 renew:
-- 
1.7.4.1

