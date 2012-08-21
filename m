Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59788 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143Ab2HUMCj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 08:02:39 -0400
Received: by yenl14 with SMTP id l14so5720087yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2012 05:02:38 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] knfsd: remove bogus BUG_ON() call from nfsd4_locku
Date: Tue, 21 Aug 2012 08:02:31 -0400
Message-Id: <1345550551-9683-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code checks for a NULL filp and handles it gracefully just before
this BUG_ON.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 566a9b7..6e12fd5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4294,7 +4294,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_lock_range;
 		goto out;
 	}
-	BUG_ON(!filp);
 	locks_init_lock(&file_lock);
 	file_lock.fl_type = F_UNLCK;
 	file_lock.fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
-- 
1.7.11.4

