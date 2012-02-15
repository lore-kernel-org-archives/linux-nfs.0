Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36744 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab2BOAmu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 19:42:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] nfsd4: fix sessions slotid wraparound logic
Date: Tue, 14 Feb 2012 19:42:44 -0500
Message-Id: <1329266566-8977-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

>From RFC 5661 2.10.6.1: "If the previous sequence ID was 0xFFFFFFFF,
then the next request for the slot MUST have the sequence ID set to
zero."

While we're there, delete some redundant comments.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e8c98f0..2095dbb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1575,16 +1575,11 @@ check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
 		else
 			return nfserr_seq_misordered;
 	}
-	/* Normal */
+	/* Note unsigned 32-bit arithmetic handles wraparound: */
 	if (likely(seqid == slot_seqid + 1))
 		return nfs_ok;
-	/* Replay */
 	if (seqid == slot_seqid)
 		return nfserr_replay_cache;
-	/* Wraparound */
-	if (seqid == 1 && (slot_seqid + 1) == 0)
-		return nfs_ok;
-	/* Misordered replay or misordered new request */
 	return nfserr_seq_misordered;
 }
 
-- 
1.7.5.4

