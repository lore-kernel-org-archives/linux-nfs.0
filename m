From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 02/44] nfsd41: slots are freed with session
Date: Tue, 16 Jun 2009 04:19:17 +0300
Message-ID: <1245115157-6865-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2365
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751875AbZFPBTR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The session and slots are allocated all in one piece.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d2851cc..d5caf2a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -580,7 +580,6 @@ free_session(struct kref *kref)
 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
 	}
-	kfree(ses->se_slots);
 	kfree(ses);
 }
 
-- 
1.6.3

